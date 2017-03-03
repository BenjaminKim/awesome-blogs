$redis = ConnectionPool::Wrapper.new(size: 12, timeout: 3) {
  Redis.new(Rails.configuration.redis_spec)
}