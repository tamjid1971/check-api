class Media < ActiveRecord::Base
  attr_accessible
  attr_accessor :project_id, :duplicated_of

  has_paper_trail on: [:create, :update]
  belongs_to :account
  belongs_to :user
  has_many :project_medias
  has_many :projects, through: :project_medias
  has_annotations

  include PenderData

  validates_presence_of :url
  validate :validate_pender_result, on: :create
  validate :pender_result_is_an_item, on: :create
  validate :url_is_unique, on: :create

  before_validation :set_user, on: :create
  after_create :set_account, :set_project
  after_rollback :duplicate

  if ActiveRecord::Base.connection.class.name != 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
    serialize :data
  end

  def user_id_callback(value, _mapping_ids = nil)
    user_callback(value)
  end

  def account_id_callback(value, mapping_ids)
    mapping_ids[value]
  end

  def tags(context = nil)
    self.annotations('tag', context)
  end

  def jsondata
    self.data.to_json
  end

  def published
    self.created_at.to_i.to_s
  end

  def associate_to_project
    if !self.project_id.blank? && !ProjectMedia.where(project_id: self.project_id, media_id: self.id).exists?
      pm = ProjectMedia.new
      pm.project_id = self.project_id
      pm.media_id = self.id
      pm.save!
    end
  end

  def last_status(context = nil)
    last = self.annotations('status', context).last
    last.nil? ? '' : last.status
  end

  def domain
    URI.parse(self.url).host.gsub(/^(www|m)\./, '')
  end

  private

  def set_user
    self.user = self.current_user unless self.current_user.nil? 
  end

  def set_account
    account = Account.new
    account.url = self.data['author_url']
    if account.save
      self.account = account
    else
      self.account = Account.where(url: account.url).last
    end
    self.save!
  end

  def pender_result_is_an_item
    unless self.data.nil?
      errors.add(:base, 'Sorry, this is not a valid media item') unless self.data['type'] == 'item'
    end
  end

  def url_is_unique
    if !CONFIG['allow_duplicated_urls']
      existing = Media.where(url: self.url).first
      self.duplicated_of = existing
      errors.add(:base, "Media with this URL exists and has id #{existing.id}") unless existing.nil?
    end
  end

  def set_project
    self.associate_to_project
  end

  def duplicate
    dup = self.duplicated_of
    unless dup.blank?
      dup.project_id = self.project_id
      dup.associate_to_project
      return false
    end
    true
  end
end
