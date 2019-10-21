require 'rails_helper'

describe ParkingsController, type: :controller do
   
   # no header accept application/json should return 406
   it 'request index and return 406 NOT ACCEPTABLE' do
       get :index
       expect(response).to have_http_status(:not_acceptable)
   end
   
   # with header accept applecation/json in index returns 200
   it 'request index and return 200 OK' do
       request.accept = 'application/json'
       get :index
       expect(response).to have_http_status(:ok)
   end
   
   it 'POST /parking invalid plate "AAA1234" 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAA1234'}}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'POST /parking invalid plate "AA1-1234" 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AA1-1234'}}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'POST /parking invalid plate "AAA-A234" 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAA-A234'}}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'POST /parking invalid plate "AA-1234" 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AA-1234'}}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'POST /parking invalid plate "AAA-234" 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAA-234'}}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'POST /parking unparked car and return 201 CREATED' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
   end
   
   it 'POST /parking parked car and return 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'PUT /parking/:id/out parked car without paying return 402 PAYMENT REQUIRED' do
       request.accept = 'application/json'
       
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id')
       put :out, params: {id: id}
       expect(response).to have_http_status(:payment_required)
   end
   
   it 'PUT /parking/:id/pay pay parking return 200 OK' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id')
       put :pay, params: {id: id}
       expect(response).to have_http_status(:ok)
   end
   
   it 'PUT /parking/:id/pay pay unparked car return 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id').to_i + 1
       put :pay, params: {id: id}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'PUT /parking/:id/out parked car held payment return 200 OK' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id')
       put :pay, params: {id: id}
       expect(response).to have_http_status(:ok)
       put :out, params: {id: id}
       expect(response).to have_http_status(:ok)
   end
   
   it 'PUT /parking/:id/pay pay parking already paid return 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id')
       put :pay, params: {id: id}
       expect(response).to have_http_status(:ok)
       put :pay, params: {id: id}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'PUT /parking/:id/out leave with car that already left the parking lot return 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id')
       put :pay, params: {id: id}
       expect(response).to have_http_status(:ok)
       put :out, params: {id: id}
       expect(response).to have_http_status(:ok)
       put :out, params: {id: id}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'PUT /parking/:id/out out unparked car return 400 BAD REQUEST' do
       request.accept = 'application/json'
       post :create, params: {parking:{plate:'AAB-1234'}}
       expect(response).to have_http_status(:created)
       response_body = JSON.parse(response.body)
       id = response_body.fetch('id').to_i + 1
       put :out, params: {id: id}
       expect(response).to have_http_status(:bad_request)
   end
   
   it 'GET /parking/:plate/plate history by plate 200 OK' do
       plates =  ["AAA-1111","BBB-2222", "AAA-1111", "AAA-1111"]
       request.accept = 'application/json'
       
       plates.each do |plate|
          post :create, params: {parking:{plate:plate}}
          expect(response).to have_http_status(:created)
          response_body = JSON.parse(response.body)
          id = response_body.fetch('id').to_i
          put :pay, params: {id: id}
          expect(response).to have_http_status(:ok)
          put :out, params: {id: id}
          expect(response).to have_http_status(:ok)
       end
       get :plate, params: {plate: plates[0]}
       response_body = JSON.parse(response.body)
       expect(response_body.size).to eql(3)
       expect(response_body[0].fetch('id')).to eql(1)
       expect(response_body[0].fetch('paid')).to eql(true)
       expect(response_body[0].fetch('left')).to eql(true)
   end
       
end