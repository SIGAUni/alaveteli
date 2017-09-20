# -*- encoding : utf-8 -*-
# app/controllers/alaveteli_pro/base_controller.rb
# Base controller for other controllers in the alaveteli_pro module.
#
# Copyright (c) 2008 UK Citizens Online Democracy. All rights reserved.
# Email: hello@mysociety.org; WWW: http://www.mysociety.org/

class AlaveteliPro::BaseController < ApplicationController

  before_filter :pro_user_authenticated?
  before_filter :set_in_pro_area

  # A pro-specific version of user_authenticated? that pro controller actions
  # can use to check for (or force a login for) an authenticated pro user
  def pro_user_authenticated?(reason_params = nil)
    if reason_params.nil?
      reason_params = {
        web: _("To access {{pro_site_name}}",
                pro_site_name: AlaveteliConfiguration.pro_site_name),
        email: _("Then you can access {{pro_site_name}}",
                pro_site_name: AlaveteliConfiguration.pro_site_name)
      }
    end
    if authenticated?(reason_params)
      unless current_user.is_pro?
        redirect_to(
          frontpage_path,
          flash: {
            notice: _("This page is only accessible to {{pro_site_name}}" \
                      " users",
                      pro_site_name: AlaveteliConfiguration.pro_site_name)
          }
        )
      end
      return true
    end
    return false
  end

  # A pro-specific version of authenticated? that pushes the user to the pro
  # signup route instead of the standard one
  def pro_authenticated?(reason_params)
    unless session[:user_id]
      reason_params.merge!(pro: true)
      post_redirect = set_post_redirect_and_headers(params, reason_params)
      # 'modal' controls whether the sign-in form will be displayed in the
      # typical full-blown page or on its own, useful for pop-ups
      redirect_to pro_signin_url(:token => post_redirect.token,
                                 :modal => params[:modal])
      return false
    end
    return true
  end

  # An override of set_in_pro_area from ApplicationController, because we are
  # always in the pro area if we're using a descendant of this controller.
  # Note that this is called as a before_filter in this class, so that
  # every descendant sets it.
  def set_in_pro_area
   @in_pro_area = true
  end

end
