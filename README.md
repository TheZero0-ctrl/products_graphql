# README

## Simple graphql api on ruby on rails

## Getting started
To get started with the app, clone the repo and then install the needed gems:
```
$ bundle install
```
Next, create database
```
$ rails db:create
```
Next, migrate the database:
```
$ rails db:migrate
```
Next, seed the database
```
$ rails db:seed
```
Finally, run the test suite to verify that everything is working correctly:
```
$ bundle exec rspec
```
If the test suite passes, you'll be ready to run the app in a local server:
first download foreman and redis and then run below comand to run rails server, sidekiq and redis at same time
```
$ foreman start
```
## Testing api
I utilized the Alrair GraphQL client, which allows for importing an API endpoint using the provided file `products_graphql.agc`.

## Creating product from csv file mechanism
- It has `BulkUpload` model for handling creation of resources from csv file.
- You have to create `bulk_upload` with params of `csv_file` and `resource_type`, in our case `resource_type` will be 'product'
- After creation of `bulk_upload` necessary bacground job will run
- You have to query previously created `bulk_upload` to view status along with data in each state
- `bulk_upload` has 6 status:
   - When first created, its status is 'pending'.
   - During CSV validation, its status changes to 'staging'.
   - Upon completion of validation, its status becomes 'staged', and it contains information about the CSV data, including total rows, valid_records, and invalid_records.
   - When it starts creating resources, its status is 'processing'.
   - After finishing resource creation, its status changes to 'processed'.
   - If any error occurs at any point, its status is set to 'failed', along with information about the error.