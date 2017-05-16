module PollsHelper

  def poll_select_options(include_all=nil)
    options = @polls.collect {|poll|
      [poll.name, current_path_with_query_params(poll_id: poll.id)]
    }
    options << all_polls if include_all
    options_for_select(options, request.fullpath)
  end

  def all_polls
    [I18n.t("polls.all"), admin_questions_path]
  end

  def poll_dates(poll)
    if poll.starts_at.blank? || poll.ends_at.blank?
      I18n.t("polls.no_dates")
    else
      I18n.t("polls.dates", open_at: l(poll.starts_at.to_date), closed_at: l(poll.ends_at.to_date))
    end
  end

  def poll_dates_select_options(poll)
    options = []
    (poll.starts_at.to_date..poll.ends_at.to_date).each do |date|
      options << [l(date, format: :long), l(date)]
    end
    options_for_select(options, params[:d])
  end

  def poll_final_recount_option(poll)
    final_date = poll.ends_at.to_date + 1.day
    options_for_select([[I18n.t("polls.final_date"), l(final_date)]])
  end

  def poll_booths_select_options(poll)
    options = []
    poll.booths.each do |booth|
      options << [booth_name_with_location(booth), booth.id]
    end
    options_for_select(options)
  end

  def booth_name_with_location(booth)
    location = booth.location.blank? ? "" : " (#{booth.location})"
    booth.name + location
  end

end