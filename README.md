# README

This project is a simple experts directory that incorporates the following:

member creation via name, personal address

member profile generated via parsing of their personal address for h1 to h3 tags

shortened website generation using bitly

friendship linking with other existing members.  friendships are bi-directional.

member profile searching which displays shortest path within network

things not done:
friendship relationship cleanup if a friend is removed, it's inverse relationship also should be cleaned up
unit tests

dummy data generation is available via rake tasks:

populate_db:new_task  to generate 50 users
populate_db:create_friendships  to generate 4 friendships per user
