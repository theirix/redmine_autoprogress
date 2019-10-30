namespace :autoprogress do
  desc <<~END_DESC
    Find affected issues and update them
  END_DESC
  task :perform => :environment do
    RedmineAutoprogress::Autoprogress.perform
  end

  desc <<~END_DESC
    Find affected issues and preview them without updating
  END_DESC
  task :preview => :environment do
    RedmineAutoprogress::Autoprogress.preview
  end
end
