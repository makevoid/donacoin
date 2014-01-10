module MechanizeUtils
  def set_cookies(options={})
    # domain: "158.167.146.140", path: "/cas", cookies: [{"MyEcasDomain" => "external"}]
    cookies = []

    options[:cookies].each do |key, value|
      cookie = Mechanize::Cookie.new key, value
      cookie.domain = options[:domain]
      cookie.path = options[:path]
      cookies << cookie
    end

    cookies.each do |cook| 
      agent.cookie_jar.add agent.history.last.uri, cook
    end
  end
end

class Mechanize
	include MechanizeUtils
end