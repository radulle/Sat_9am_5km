# frozen_string_literal: true

class Activity < ApplicationRecord
  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
  has_many :volunteers, dependent: :destroy

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }

  def leader_result(male: true)
    results.joins(:athlete).where(athlete: { male: male }).order(:position).first
  end

  def add_results_from_timer(file_timer)
    return unless file_timer

    transaction do
      table = CSV.parse(file_timer.read, headers: false)
      raise 'Unknown timer file format' if table.dig(0, 0) != 'STARTOFEVENT'

      self.date = Date.parse(table.dig(0, 1)) # Date of event in the second column of first row
      table[2..].each do |row|
        break if row.first == 'ENDOFEVENT'

        results << Result.new(position: row.first, total_time: row.last)
      end
      save!
    end
  end

  def add_results_from_scanner(file_scanner)
    return unless file_scanner

    table = CSV.parse(file_scanner.read, headers: false)
    return unless table.dig(1, 0).match?(/A\d+/)

    table[1..].each do |row|
      AddAthleteToResultJob.perform_later(self, row)
    end
  end
end
