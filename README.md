# Holiday Plans Oxizuo
Holiday Plans Oxizuo is a simple API intended for handling  employees vacation requests. The design of the app implies that every employee can be a subordinate of some manager and a manager to some another subordinate at the same time, and only the manager of an request author can approve the request.

## Endpoints and features
 1. **GET   /requests/:employee_id/mine** - the endpoint calling which an *employee* can see all his/her own requests.
 2. **POST  /requests(.:format)** - the endpoint calling which an *employee* can create a new request, required params: *employee_id, start_date, end_date* .
 3. **GET   /requests/:employee_id/to_resolve** - the endpoint calling which a *manager* can see all requests created by his/her subordinates, filter them by date and this way check if there is more than 1 subordinate who is gonna be absent on the provided date, optional params: *date*.
 4. **PATCH /requests/:id(.:format)**  - the endpoint calling which a *manager* can either approve or reject pending request or  change the status of a resolved request back to "pending", required params:  employee_id (manager ID), status.                                      
 5. **GET /employees/:employee_id/employee_remaining_vacation_days** - the endpoint calling which an *employee* can check the number of non-taken yet vacation days in this calendar year.
 6.
# Technical details
* Programming language: Ruby 2.7.1,
* Framework: Rails 6.0.4.1
* DBMS: PostgreSQL
* ORM Framework: ActiveRecord
* Testing tool: Rspec

# How to run the app

 1. Clone the repository from GitHub / extract it from the archive.
 2. Navigate to the app folder.
 3. Make sure PostgreSQL and Ruby 2.7.1 are installed on your machine.
 4. Run in the command line 'bundle install'.
 5. Rename the file '.../config/database.yml.example' to '.../config/database.yml', Open it and put there a real DB credentials valid for your local database.
 6. Run 'bin/rails db:create'.
 7. Run 'bin/rails db:migrate'.
 8. Run 'bin/rails server'

To run the specs navigate to the app folder and run 'bundle exec rspec' in the command line,
