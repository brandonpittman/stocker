Feature: Check home directory
  In order to check ENV['HOME']
  As a cool guy
  I want to be sure I'm at home

  Scenario: Check ENV['HOME']
    Given I have entered ENV['HOME']
    Then the result should be '/Users/brandonpittman'