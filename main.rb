#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'

require_relative 'lib/dashboard/dashboard'

# Ponto de entrada principal do Dashboard CLI
Dashboard::Dashboard.new.run
