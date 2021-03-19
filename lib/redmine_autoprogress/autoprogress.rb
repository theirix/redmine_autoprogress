module RedmineAutoprogress
  class Autoprogress
    def self.enumerate_issues
      tag = Setting.plugin_redmine_autoprogress['tag']
      projects = Setting.plugin_redmine_autoprogress['projects'].map { |pid| Project.find(pid) }
      STDERR.puts("Check autoprogress for tag #{tag} and projects #{projects.map(&:name).join(', ')}")

      projects.each do |project|
        project.issues.open.each do |issue|
          next unless issue.start_date && issue.due_date && issue.due_date > issue.start_date
          next unless issue.tag_list.include?(tag)
          next if issue.done_ratio_derived?

          # check if progress differs
          progress_ratio = (Date.today - issue.start_date) / (issue.due_date - issue.start_date)
          # progress_ratio<1, progress should be in progress * 10
          # so round it by tenth - 60, 70 ... 100
          progress = (progress_ratio * 10).round * 10
          # cap by 100
          progress = [0, [progress, 100].min].max
          # done_ratio must be not the same
          next unless issue.done_ratio.nil? || issue.done_ratio != progress

          yield [issue, progress]
        end
      end
    end

    def self.preview
      enumerate_issues do |issue, progress|
        STDERR.puts("Preview issue \##{issue.id} (#{issue.subject}), " \
          "in project '#{issue.project.name}' with progress #{progress}")
      end
    end

    def self.perform
      Mailer.with_synched_deliveries do
        enumerate_issues do |issue, progress|
          STDERR.puts "Autoprogressing issue \##{issue.id} (#{issue.subject}) "\
            "with progress #{progress}"
          issue.done_ratio = progress
          issue.save(validate: false)
        end
      end
    end
  end
end
