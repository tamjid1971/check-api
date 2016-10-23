class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    fields = options[:fields] + [attribute]
    matches = []
    fields.each do |field|
      matches << { match: { field => record.send(field).to_s } }
    end
    existing = record.class.search(query: { bool: { must: matches } }).results.select{ |a| a.send(attribute) === record.send(attribute) }
    unless existing.empty?
      message = "This #{attribute} already exists"
      record.errors[attribute] << message
      raise message
    end
  end
end
