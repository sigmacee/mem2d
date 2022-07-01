module AuthenticationController

using Genie, Genie.Renderer, Genie.Renderer.Html, Genie.Flash   #, Genie.Router
using SearchLight
using GenieAuthentication
using ViewHelper
using Users
using Logging
using Random


function show_login()
  html(:authentication, :login, context = @__MODULE__)
end

function login()
  try
    user = findone(User, username = params(:username), password = Users.hash_password(params(:password)))
    authenticate(user.id, Genie.Sessions.session(params()))

    redirect(:success)
  catch ex
    flash("Authentication failed! ")

    redirect(:show_login)
  end
end

function success()
  authenticated() || throw(ExceptionalResponse(redirect(:show_login)))
  user_id = get_authentication()  # 由session中取得user_id
  na = SearchLight.query("select name from users where id = $user_id") |> Array  # 通过user_id取员工姓名
  aut = SearchLight.query("""select email from users where id = $user_id""") |> Array

    #if isempty(aut)
     #   aut1 = ""
    #else
     #   aut1 = split(aut[1],",")
    #end

  bb = readdir("""./public/dog""")
  aa = rand(bb)
  fname = aa
  html(:authentication, :success, 
       name=na[1],
       aut=aut[1],
       fn=fname,
       context = @__MODULE__, 
       layout=:projlayout)
end

function logout()
  deauthenticate(Genie.Sessions.session(params()))

  flash("Good bye! ")

  redirect(:show_login)
end

function show_register()
  html(:authentication, :register, context = @__MODULE__)
end

function register()
  try
    maxID = SearchLight.query("select max(id) from users") |> Array

    user = User(username  = params(:username),
                password  = params(:password) |> Users.hash_password,
                name      = params(:name),
                email     = params(:email)) #|> save!
    user.id = maxID[1] + 1
    SearchLight.query("""insert into users values ($(user.id),'$(user.username)','$(user.password)','$(user.name)','$(user.email)')""")
    authenticate(user.id, Genie.Sessions.session(params()))

    "Registration successful"
  catch ex
    @error ex

    if hasfield(typeof(ex), :msg)
      flash(ex.msg)
    else
      flash(string(ex))
    end

    redirect(:show_register)
  end
end

end