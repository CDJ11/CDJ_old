module Budgets
  module Ballot
    class LinesController < ApplicationController
      before_action :authenticate_user!
      #before_action :ensure_final_voting_allowed
      before_action :load_budget
      before_action :load_ballot
      before_action :load_tag_cloud
      before_action :load_categories
      before_action :load_investments
      before_action :load_ballot_referer

      load_and_authorize_resource :budget
      load_and_authorize_resource :ballot, class: "Budget::Ballot", through: :budget
      load_and_authorize_resource :line, through: :ballot, find_by: :investment_id, class: "Budget::Ballot::Line"

      def create
        load_investment
        load_heading

        unless @ballot.add_investment(@investment)
          head :bad_request
        end
      end

      def destroy
        @investment = @line.investment
        load_heading

        @line.destroy
        load_investments
        #@ballot.reset_geozone
      end

      private

        def ensure_final_voting_allowed
          return head(:forbidden) unless @budget.balloting?
        end

        def line_params
          params.permit(:investment_id, :budget_id)
        end

        def load_budget
          @budget = Budget.find(params[:budget_id])
        end

        def load_ballot
          @ballot = Budget::Ballot.where(user: current_user, budget: @budget).first_or_create
        end

        def load_investment
          @investment = Budget::Investment.find(params[:investment_id])
        end

        def load_investments
          if params[:investments_ids].present?
            @investment_ids = params[:investments_ids]
            @investments = Budget::Investment.where(id: params[:investments_ids])
          end
        end

        def load_heading
          @heading = @investment.heading
        end

        def load_tag_cloud
          @tag_cloud = TagCloud.new(Budget::Investment, params[:search])
        end

        def load_categories
          @categories = ActsAsTaggableOn::Tag.where("kind = 'category'").order(:name)
        end

        def load_ballot_referer
          @ballot_referer = session[:ballot_referer]
        end

    end
  end
end
