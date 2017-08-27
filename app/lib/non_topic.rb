class NonTopic
  def redis_key
    @redis_key ||= 'awesome-blogs:non-topic'.freeze
  end

  def expire_time
    if Rails.env.production?
      20.days
    else
      2.minutes
    end
  end

  def drop_old
    $redis.zremrangebyscore(redis_key, '-inf', (Time.now - expire_time).to_i)
  end

  def add(url, drop = true)
    if drop
      drop_old
    end
    $redis.zadd(redis_key, Time.now.to_i, url)
  end

  def list
    @list ||= $redis.zrange(redis_key, 0, -1)
  end

  def list_with_score
    $redis.zrangebyscore(redis_key, '-inf', '+inf', with_scores: true)
  end

  def list_to_be_expired
    $redis.zrangebyscore(redis_key, '-inf', (Time.now - expire_time).to_i)
  end

  def in?(url)
    list.include?(url)
  end
end