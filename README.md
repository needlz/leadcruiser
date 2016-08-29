## Leadcruiser

Purpose of Leadcruiser is to store and forward [leads](https://en.wikipedia.org/wiki/Lead_generation) to client services.

App stores leads information, provides API for receiving leads, forwards leads to the clients APIs. Stored leads are being forwarded to api of clients (“clients verticals”). Clients pay to the owner for  received leads.

App has only three parts with UI: admin pages, reports pages, and Sidekiq dashboard.

There are two “verticals” (topics) of data: pet and health insurances. Initially, app handled only pet insurances, it tracks visitors, clicks and leads for this vertical. Later health insurance vertical was added, and it tracks only leads for the vertical.

App is configured to save db backups from Heroku platform and save them to Amazon S3.

## Installation

Besides database you need to install Redis server in order to start Sidekiq background worker.

## API Reference

GET    /api/v1/leads api/v1/leads#index - creates health lead
POST   /api/v1/leads api/v1/leads#create creates health or pet lead
POST   /api/v1/visitors api/v1/visitors#create - create visitor record
POST   /api/v1/clicks api/v1/clicks#create - create click record
POST   /api/v1/clients api/v1/clients#create - get list of available clients
POST   /api/v1/zipcodes api/v1/zipcodes#create - get location onfo by zipcode

## Tests

RSpec is used as tests framework. Use `rspec` to run test suite.
