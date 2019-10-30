Rails.configuration.to_prepare do
  unless Redmine::Plugin.registered_plugins[:redmine_tags]
    # plugin requirement
    raise 'Plugin requires Redmine Tags to be installed'
  end
end

Redmine::Plugin.register :redmine_autoprogress do
  name 'Redmine Autoprogress plugin'
  author 'Eugene Seliverstov'
  description 'Autoprogress plugin'
  version '0.0.1'
  url 'http://github.com/theirix/redmine_autoprogress'

  requires_redmine version_or_higher: '4.0.0'

  settings(default: { projects: [],
                      tag: nil },
           partial: 'settings/autoprogress_settings')
end