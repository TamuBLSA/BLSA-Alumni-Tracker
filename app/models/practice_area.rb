class PracticeArea < ApplicationRecord
  has_many :users, through: :area_joins
  has_many :area_joins
end
