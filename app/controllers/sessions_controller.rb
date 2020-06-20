class SessionsController < ApplicationController
  def new
  end

  def create 
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      #log the user in and redirect to user page
      if @user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user) 
        redirect_to forwarding_url || @user
      else 
        message = "Account not activated. "
        message += "Check your email for the activation link"
        flash[:warning] = message
        redirect_to root_url
      end
    else 
      #create an error message
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
