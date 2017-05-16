class Admin::SettingsController < Admin::BaseController

  def index
    all_settings = (Setting.all).group_by { |s| s.type  }
    @settings = all_settings['common']
    @feature_flags = all_settings['feature']
    @banner_styles = all_settings['banner-style']
    @banner_imgs = all_settings['banner-img']
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update(settings_params)
    redirect_to admin_settings_path, notice: t("admin.settings.flash.updated")
  end

  private

    def settings_params
      params.require(:setting).permit(:value)
    end

end