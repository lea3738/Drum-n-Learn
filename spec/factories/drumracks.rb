FactoryBot.define do
  factory :drumrack do
    name { "Example Drumrack" }
    bpm { 120 }
    genre { "Example Genre" }
    is_template { false }
  end
end
