module SteakFM
  class Feature < Struct.new(:path, :cfm)

#    include FeatureElement::Component::TotalEstimation

    include SteakFM::FeatureElement::Component::Story
    include SteakFM::FeatureElement::Component::Title
    include SteakFM::FeatureElement::Component::MetaInfo
    include SteakFM::FeatureElement::Component::MetaInfoExt::TotalEffort

    FEATURE_PATTERN = /((^.*#+.*\n)+\n?)?(^.*@+.*\n)?^[ \t]*feature ".*"/

    alias_method :narration, :story

    def id
      Base64.encode64(relative_path)
    end

    def relative_path
      path.gsub(/^#{cfm.path}\//, '')
    end

    def file_raw
      @file_raw ||= read_content_from_file
    end

    def file_raw= content
      @file_raw = content
    end

    def info
      @info ||= FeatureElement::Info.new(self, scan_for_feature_info_from_raw)
    end

    def background
      @background ||= FeatureElement::Background.new(self, scan_for_background_from_raw)
    end

    def scenarios
      @scenarios ||= fetch_scenarios
    end

#    def tags
#      info.tags
#    end
#
#    def tags_all
#      scenarios.collect { |scenario| scenario.tags }.flatten.uniq
#    end

    def save
      write_content_to_file
#      commit
#      push
#      true
    end

    def destroy
      File.delete(path)
      remove_file_from_repo
      push
    end

    def filename
      File.basename(path)
    end

    def filename_without_extension
      File.basename(path, '_spec.rb')
    end

    def <=>(_f)
      info.title <=> _f.info.title
    end

    def valid?
      file_raw =~ FEATURE_PATTERN
    end

    private

    def read_content_from_file
      File.open(path, 'r') { |stream| stream.read }
    end

    def write_content_to_file
      File.open(path, 'w') { |stream| stream.write file_raw }
    end


#    # TODO we need to detect it in more clever way
#    def commit
#      cfm.commit_change_on(self) if do_commit?
#    end
#
#    # TODO we need to detect it in more clever way
#    def push
#      cfm.send_to_remote if do_push?
#    end
#
#    def remove_file_from_repo
#      cfm.remove_file_from_repo(relative_path) if do_commit?
#    end
#
#    def do_push?
#      cfm && cfm.respond_to?(:send_to_remote) && cfm.config.cvs_commit=='1' && cfm.config.cvs_push=='1'
#    end
#
#    def do_commit?
#      cfm && cfm.respond_to?(:commit_change_on) && cfm.config.cvs_commit=='1'
#    end

    def fetch_scenarios
      scenarios = []
      text = file_raw
      while match = FeatureElement::Scenario::PATTERN.match(text)
        FeatureElement::Scenario.new(self, match[0]).tap do |scenario|
#          scenarios.push(scenario) if cfm.filter.pass?(scenario.tags)
          scenarios.push(scenario)
        end
        text = match.post_match
      end
      scenarios
    end

    def raw
      if match = FEATURE_PATTERN.match(file_raw)
        match[0]
      else
        ''
      end
    end

    def scan_for_background_from_raw
      if match = FeatureElement::Background::PATTERN.match(file_raw)
        match[0]
      else
        ''
      end
    end

  end
end