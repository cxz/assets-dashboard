class BeaconMonitor
  KEY = "recent_beacons" # redis key
  STORE_LIMIT = 1000
  POLL_INTERVAL = 0.5

  def initialize
    @beacons = []
  end

  def on_change
    loop do
      sleep POLL_INTERVAL

      #retrieve updated list of beacons readings
      #we reverse the order because so last readings have precedence
      updated = Hash[$redis.lrange(KEY, 0, -1).reverse.collect do |raw|
        beacon = JSON.parse(raw).with_indifferent_access
        beacon[:id] = beacon_key(beacon)
        [beacon[:id], beacon]
      end]

      updated.each do |id, beacon|
        if !@beacons.include? id
          yield(beacon, 'added')

        elsif @beacons[id] != beacon
          yield(beacon, 'updated')
        end
      end

      @beacons.delete_if do |id, beacon|
        if updated.include? id
          false

        else
          yield(beacon, 'removed')
          true
        end
      end

      @beacons = updated
    end
  ensure
    #
  end

  private

  def beacon_key(beacon)
    Digest::SHA256.hexdigest([beacon[:uuid], beacon[:sensor]].join('-'))
  end
end