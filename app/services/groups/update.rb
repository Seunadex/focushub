module Groups
  class Update
    Result = Struct.new(:success?, :group, :error_message, keyword_init: true)

    def self.call(group:, params:)
      if group.update(params)
        Result.new(success?: true, group: group, error_message: nil)
      else
        Result.new(success?: false, group: group, error_message: group.errors.full_messages.to_sentence)
      end
    end
  end
end
