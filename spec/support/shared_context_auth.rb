RSpec.shared_context 'with authenticated user' do
  let!(:user) { User.first }

  before { sign_in(user) }
end
