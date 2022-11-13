# frozen_string_literal: true

class AthleteAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id)
    @activity = Activity.find activity_id
    return unless @activity.published

    [true, false].each { |male| process_event_records(male: male) }
    @activity.athletes.each { |athlete| award_runner(athlete) }
    @activity.volunteers.each { |volunteer| award_volunteer(volunteer.athlete) }
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def process_event_records(male:)
    best_result = @activity.results.joins(:athlete).where(athlete: { male: male }).order(:total_time, :position).first
    return unless best_result

    record_badge = Badge.record_kind.find_by("(info->'male')::boolean = ?", male)
    trophies = Trophy.where(badge: record_badge).where("info @@ '$.data[*].event_id == ?'", event_id)
    award_record_badge(record_badge, best_result) and return if trophies.empty?

    award_best_result = false
    Trophy.transaction do
      trophies.each do |trophy|
        records_data = trophy.info['data']
        record_data = records_data.find { |d| d['event_id'] == event_id }
        record_result = Result.find(record_data['result_id'])
        next if best_result.total_time > record_result.total_time || best_result.activity.date < record_result.activity.date

        award_best_result ||= true
        records_data.delete(record_data)
        if best_result.athlete_id == record_result.athlete_id
          trophy.info['data'] = [*records_data, { event_id: event_id, result_id: best_result.id }]
          trophy.save!
          next
        end
        trophy.destroy and next if records_data.empty?

        trophy.info['data'] = records_data
        trophy.save!
      end
    end
    return if !award_best_result || trophies.exists?(athlete_id: best_result.athlete_id)

    award_record_badge(record_badge, best_result)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def award_runner(athlete)
    results = athlete.results.joins(:activity).where(activity: { published: true, date: ..activity_date })
    participating_badges_dataset(type: 'athlete').each do |badge|
      next if results.size < badge.info['threshold']

      athlete.award_by Trophy.new(badge: badge, date: activity_date)
    end
    events_count = results.joins(activity: :event).select('events.id').distinct.count
    tourist_badge = Badge.tourist_kind.where("info->>'type' = 'athlete'").take
    if events_count >= tourist_badge.info['threshold']
      athlete.award_by Trophy.new(badge: tourist_badge, date: activity_date)
    end
    athlete.save!
  end

  def award_volunteer(athlete)
    volunteering = athlete.volunteering.where(activity: { date: ..activity_date })
    participating_badges_dataset(type: 'volunteer').each do |badge|
      next if volunteering.size < badge.info['threshold']

      athlete.award_by Trophy.new(badge: badge, date: activity_date)
    end
    events_count = volunteering.joins(activity: :event).select('events.id').distinct.count
    tourist_badge = Badge.tourist_kind.where("info->>'type' = 'volunteer'").take
    if events_count >= tourist_badge.info['threshold']
      athlete.award_by Trophy.new(badge: tourist_badge, date: activity_date)
    end
    athlete.save!
  end

  def participating_badges_dataset(type:)
    Badge.participating_kind.where("info->>'type' = ?", type).order(Arel.sql("info->'threshold'"))
  end

  def activity_date
    @activity_date ||= @activity.date
  end

  def event_id
    @event_id ||= @activity.event_id
  end

  def award_record_badge(badge, result)
    Trophy.create(
      badge: badge,
      athlete_id: result.athlete_id,
      info: { data: [{ event_id: event_id, result_id: result.id }] }
    )
  end
end
