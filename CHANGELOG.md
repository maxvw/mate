# Changelog

## 0.1.7 (unrelease)
  * [Storage] added a new storage driver system
  * [Storage.Local] the default storage engine (local machine)

## 0.1.6
  * [test] added way ot test Local driver on CI
  - [StopRelease] added new step to stop the release before unarchiving the new one
  * [doc] updated docs

## 0.1.5
  * [mix mate.build] added new build-only command
  * [StartRelease] fixed bash script to do a real restart
  * [test] added way to test Docker driver on CI

## 0.1.4
  * [Driver.SSH] fixed bug with multiple deploy hosts
  * [test] updated test and typespecs

## 0.1.3
  * [Driver.Local] added localhost driver
  * [mix mate.init] added `--local` option for localhost

## 0.1.2
  * [Driver.Docker] added docker driver
  * [mix mate.init] added `--docker` option for docker usage

## 0.1.1
  * [tests] updated typespecs and added dialyzer
  * [doc] updated docs

## 0.1.0
  * the first release
