module Groups
  class Create
    Result = Struct.new(:success?, :group, :error_message, keyword_init: true)

    def self.call(params:, creator:)
      group = Group.new(params)

      Group.transaction do
        if group.save
          group.group_memberships.create!(
            user: creator,
            role: "owner",
            joined_at: Time.current,
            status: "active"
          )
          return Result.new(success?: true, group: group, error_message: nil)
        else
          return Result.new(success?: false, group: group, error_message: group.errors.full_messages.to_sentence)
        end
      end
    rescue StandardError => e
      Result.new(success?: false, group: group, error_message: e.message)
    end
  end
end
