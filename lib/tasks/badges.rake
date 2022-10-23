# frozen_string_literal: true

namespace :badges do
  desc 'Award participants of activity'
  task :award_participants, %i[activity_id badge_id] => :environment do |_, args|
    activity = Activity.find args.activity_id
    badge = Badge.find args.badge_id

    activity.athletes.each do |athlete|
      athlete.award_by Trophy.new(badge: badge, date: activity.date)
      Rails.logger.error(athlete.errors.inspect) unless athlete.save
    end

    activity.volunteers.each do |volunteer|
      volunteer.athlete.award_by Trophy.new(badge: badge, date: activity.date)
      Rails.logger.error(volunteer.athlete.errors.inspect) unless volunteer.athlete.save
    end
  end

  desc 'Awardings for last week'
  task weekly_awarding: :environment do
    activities = Activity.where(date: Date.current.all_week)
    activities.each do |activity|
      AthleteAwardingJob.perform_now(activity.id)
    end
    BreakingTimeAwardingJob.perform_now
  end
end
