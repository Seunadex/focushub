module Groups
  class Destroy
    Result = Struct.new(:success?, :group, :error_message, keyword_init: true)

    def self.call(group:)
      if group.destroy
        Result.new(success?: true, group: group, error_message: nil)
      else
        Result.new(success?: false, group: group, error_message: group.errors.full_messages.to_sentence)
      end
    end
  end
end
