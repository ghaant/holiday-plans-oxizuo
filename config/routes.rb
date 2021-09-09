Rails.application.routes.draw do
  get '/requests/:employee_id/mine', to: 'requests#employee_requests'
  post '/requests/', to: 'requests#create'
  get '/requests/:employee_id/to_resolve', to: 'requests#requests_to_resolve'
  get '/employees/:employee_id/employee_remaining_vacation_days/', to: 'users#employee_remaining_vacation_days'
  patch '/requests/:id', to: 'requests#resolve'
end
