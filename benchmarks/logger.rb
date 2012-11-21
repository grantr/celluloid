#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'celluloid'
require 'benchmark/ips'
require 'logger'

puts "==== Ruby standard logger ===="
standard_logger = ::Logger.new(IO::NULL)
Benchmark.ips do |ips|
  ips.report("standard")    { standard_logger.error("average error message") }
end
standard_logger = nil

puts "==== below level  ===="
logger = Celluloid::IncidentLogger.new
Benchmark.ips do |ips|
  ips.report("below level") { logger.trace("average trace message") }
end
logger = nil

puts "==== without consumers ===="
logger = Celluloid::IncidentLogger.new
Celluloid::Actor[:default_incident_reporter].terminate
Benchmark.ips do |ips|
  ips.report("events w/o consumers")  { logger.debug("average debug message") }
  ips.report("incidents w/o consumers") { logger.error("average error message") }
end
logger = nil

puts "==== with incident reporter ===="
logger = Celluloid::IncidentLogger.new
reporter = Celluloid::IncidentReporter.new(IO::NULL)
Benchmark.ips do |ips|
  ips.report("events w/ inc reporter")  { logger.debug("average debug message") }
  ips.report("incidents w/ inc reporter") { logger.error("average error message") }
end
logger = nil
reporter.terminate

puts "==== with incident reporter and event reporter ===="
logger = Celluloid::IncidentLogger.new
reporter = Celluloid::IncidentReporter.new(IO::NULL)
consumer = Celluloid::EventReporter.new(IO::NULL)
Benchmark.ips do |ips|
  ips.report("events w/ reporters")  { logger.debug("average debug message") }
  ips.report("incidents w/ reporters") { logger.error("average error message") }
end
