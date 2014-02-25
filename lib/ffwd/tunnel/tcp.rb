# $LICENSE
# Copyright 2013-2014 Spotify AB. All rights reserved.
#
# The contents of this file are licensed under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require_relative '../lifecycle'
require_relative '../reporter'

module FFWD::Tunnel
  class TCP
    include FFWD::Lifecycle
    include FFWD::Reporter

    setup_reporter :keys => [
      :received_events, :received_metrics, :failed_events, :failed_metrics]

    attr_reader :log

    def initialize port, core, plugin, log, connection, args
      @port = port
      @core = core
      @plugin = plugin
      @log = log
      @connection = connection
      @args = args

      starting do
        @plugin.tcp @port do |handle|
          log.debug "Open tcp/#{@port}"

          instance = @connection.new(nil, self, @core, *@args)
          instance.datasink = handle

          handle.data do |data|
            instance.receive_data data
          end

          handle.close do
            log.debug "Close tcp/#{@port}"
            instance.unbind
          end
        end
      end

      stopping do
        log.info "Stopped tunneling tcp/#{@port}"
      end
    end
  end
end
