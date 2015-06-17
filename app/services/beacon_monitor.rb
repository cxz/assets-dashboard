class BeaconMonitor
  KEY = "recent_beacons" # redis key
  STORE_LIMIT = 1000

  def on_change
    #todo: subscribe
    loop do
      sleep 1

      beacons = $redis.lrange(KEY, 0, -1).collect do |raw|
        JSON.parse(raw).with_indifferent_access
      end

      #todo: uuid is not an ID because multiple sensors could identify the same beacon
      #what could we use as ID so that we detect which entries changed?
      #perhaps beacon-id + sensor-id
      yield(beacons, 'change')

    end
  ensure
    #todo: unsubscribe
  end
end