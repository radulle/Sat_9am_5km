class Rack::Attack
  # Throttle requests by IP
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # Allows 10 requests in 3  seconds
  #        20 requests in 9  seconds
  #        30 requests in 27 seconds
  #        40 requests in 81 seconds
  (1..4).each do |level|
    throttle('req/ip', limit: 10 * level, period: (3**level).seconds) do |req|
      req.ip if req.path.start_with?('/activities') || req.path.start_with?('/athletes') || req.path.start_with?('/user')
    end
  end

  blocklist('fail2ban pentesters') do |req|
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.day) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} || req.path.end_with?('.php')
    end
  end

  blocklist('block pentester logins') do |req|
    bad_user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' \
      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'
    req.path.start_with?('/user') && req.post? && req.user_agent == bad_user_agent
  end
end
