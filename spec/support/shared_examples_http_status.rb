RSpec.shared_examples 'successful status' do
  it 'returns successful http status code' do
    expect(response).to have_http_status(:successful)
  end
end
