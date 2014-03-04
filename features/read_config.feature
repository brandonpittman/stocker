@config
Feature: Read Stocker config file
  In order to set a default url for new items
  And to set a default minimum for power users
  I want to create and read from a config.yaml file

@announce
Scenario: Try reading config when it doesn't exist
  Given a file named ".stocker.config.yaml" with:
  """
  ---
  test:
    total: 2
    min: 1
    url: http://amazon.com
    checked: 2014-03-03 19:00:55.518969000 +09:00
  """
  When I run `cat .stocker.config.yaml`
  Then the output should contain:
  """
  ---
  test:
    total: 2
    min: 1
    url: http://amazon.com
    checked: 2014-03-03 19:00:55.518969000 +09:00
  """
