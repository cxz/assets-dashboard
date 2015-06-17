class RecentBeacons
  KEY = "recent_beacons" # redis key
  STORE_LIMIT = 1000      # how many beacons should be kept

  # Get list of recent beacons from redis
  # Since redis stores data in binary text format
  # we need to parse each list item as JSON
  def self.list(limit = STORE_LIMIT)
    $redis.lrange(KEY, 0, limit-1).map do |raw_post|
      JSON.parse(raw_post).with_indifferent_access
    end
  end

  # Push new  beacon to list and trim it's size
  # to limit required storage space
  # `raw_post` is already a JSON string
  # so there is no need to encode it as JSON
  def self.push(raw_beacon)
    $redis.lpush(KEY, raw_beacon)
    $redis.ltrim(KEY, 0, STORE_LIMIT-1)
  end
end