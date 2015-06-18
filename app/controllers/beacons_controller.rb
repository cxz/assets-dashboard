class BeaconsController < ApplicationController
  include ActionController::Live

  def index
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, retry: 300)
    begin

      BeaconMonitor.new.on_change do |beacon, event|
        sse.write(beacon, event: event)
      end

    rescue ActionController::Live::ClientDisconnected
      #no problem.
    rescue IOError
      #client disconnected
    ensure
      sse.close
    end
    render nothing: true
  end
end