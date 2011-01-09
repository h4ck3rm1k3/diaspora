module YoutubeTitles
  def youtube_title_for video_id
    http = Net::HTTP.new('gdata.youtube.com', 80)
    path = "/feeds/api/videos/#{video_id}?v=2"
    resp, data = http.get(path, nil)
    title = data.match(/<title>(.*)<\/title>/)
    unless title.nil?
      title = title.to_s[7..-9]
    end
    title || I18n.t('application.helper.video_title.unknown')
  end
  def get_youtube_title text
#    self.youtube_titles ||= {}
    self[:youtube_titles] ||= {}

    youtube_match = text.match(YOUTUBE_ID_REGEX)

    return unless youtube_match
    p "youtube match"
    p youtube_match

    p "looking for youtube in text" 
    p text

    video_id = youtube_match[1]
    p video_id
    unless self[:youtube_titles][video_id]
      self[:youtube_titles][video_id] = youtube_title_for(video_id)
    end
    p "results:"
    p self[:youtube_titles]

  end
  YOUTUBE_ID_REGEX = /youtube\.com.*?v=([A-Za-z0-9_\\\-]+)/ unless defined? YOUTUBE_ID_REGEX
end
