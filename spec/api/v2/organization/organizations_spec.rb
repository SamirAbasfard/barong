# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Organization::Organizations, type: :request do
  include_context 'bearer authentication'
  include_context 'organization memberships'

  describe 'GET /api/v2/organization/all' do
    let(:do_request) { get '/api/v2/organization/all', headers: auth_header }

    it 'error when account not found' do
      do_request

      expect(response.status).to eq 401
    end

    context 'user is barong organization admin' do
      let(:test_user) { User.find(1) }

      it 'get all organizations and accounts' do
        do_request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.length).to eq 2
      end
    end

    context 'user is organization admin' do
      let!(:create_memberships) do
        # Assign user as organization admin
        create(:membership, id: 1, user_id: 2, organization_id: 1)
      end
      let(:test_user) { User.find(2) }

      it 'got error for organization admin' do
        do_request

        expect(response.status).to eq 401
      end
    end

    context 'user is organization member' do
      let!(:create_memberships) do
        # Assign user as organization member
        create(:membership, id: 1, user_id: 3, organization_id: 3)
      end
      let(:test_user) { User.find(3) }

      it 'got error for organization admin' do
        do_request

        expect(response.status).to eq 401
      end
    end
  end

  describe 'POST /api/v2/organization' do
    context 'when params is missing' do
      it 'renders an error' do
        post '/api/v2/organization',
             headers: auth_header
        expect_status_to_eq 422
      end
    end

    context 'when params is valid' do
      context 'user is normal user' do
        let(:test_user) { User.find(7) }
        it 'deny to create organization for normal user' do
          post '/api/v2/organization',
               params: { name: 'Company Test', group: 'vip-1' },
               headers: auth_header

          expect(response.status).to eq(401)
        end
      end

      context 'user has Organization ability' do
        let(:test_user) { User.find(1) }
        it 'create organization' do
          post '/api/v2/organization',
               params: { name: 'Company Test', group: 'vip-1' },
               headers: auth_header

          expect(response.status).to eq(201)
          expect(::Organization.last.name).to eq('Company Test')
        end
      end
    end
  end
end