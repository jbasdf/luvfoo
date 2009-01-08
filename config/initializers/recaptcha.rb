if GlobalConfig.use_recaptcha
  ENV['RECAPTCHA_PUBLIC_KEY'] = GlobalConfig.recaptcha_pub_key
  ENV['RECAPTCHA_PRIVATE_KEY'] = GlobalConfig.recaptcha_priv_key
end
