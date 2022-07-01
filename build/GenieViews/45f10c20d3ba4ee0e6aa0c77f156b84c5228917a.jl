# app\resources\authentication\views\login.jl.html 

function func_45f10c20d3ba4ee0e6aa0c77f156b84c5228917a(;
    context = Genie.Renderer.vars(:context),
)

    [
        Genie.Renderer.Html.div(class = "h2", htmlsourceindent = "2") do
            [
                """Welcome""";
            ]
        end
        Genie.Renderer.Html.br(htmlsourceindent = "2")
        Genie.Renderer.Html.div(
            class = "bs-callout bs-callout-primary",
            htmlsourceindent = "2",
        )
        Genie.Renderer.Html.div(class = "h1", htmlsourceindent = "2") do
            [
                """
                    Please login here
                  """
            ]
        end
        Genie.Renderer.Html.br(htmlsourceindent = "2")
        Genie.Renderer.Html.div(class = "h1", htmlsourceindent = "2") do
            [
                Genie.Renderer.Html.span(htmlsourceindent = "3") do
                    [
                        """$(output_flash())""";
                    ]
                end;
            ]
        end
        Genie.Renderer.Html.br(htmlsourceindent = "2")
        Genie.Renderer.Html.div(class = "aa", htmlsourceindent = "2") do
            [
                Genie.Renderer.Html.div(class = "h3", htmlsourceindent = "3") do
                    [
                        Genie.Renderer.Html.form(
                            method = "POST",
                            enctype = "multipart/form-data",
                            action = "$(linkto(:login))",
                            class = "",
                            htmlsourceindent = "4",
                        ) do
                            [
                                Genie.Renderer.Html.div(
                                    class = "form-group",
                                    htmlsourceindent = "5",
                                ) do
                                    [
                                        Genie.Renderer.Html.label(
                                            htmlsourceindent = "6",
                                            ;
                                            NamedTuple{(:_for,)}(("auth_username",))...,
                                        ) do
                                            [
                                                """username """;
                                            ]
                                        end
                                        Genie.Renderer.Html.input(
                                            name = "username",
                                            class = "form-control",
                                            id = "auth_username",
                                            htmlsourceindent = "6",
                                            placeholder = "User",
                                            type = "text",
                                        )
                                    ]
                                end
                                Genie.Renderer.Html.br(htmlsourceindent = "5")
                                Genie.Renderer.Html.div(
                                    class = "form-group",
                                    htmlsourceindent = "5",
                                ) do
                                    [
                                        Genie.Renderer.Html.label(
                                            htmlsourceindent = "6",
                                            ;
                                            NamedTuple{(:_for,)}(("auth_password",))...,
                                        ) do
                                            [
                                                """password """;
                                            ]
                                        end
                                        Genie.Renderer.Html.input(
                                            name = "password",
                                            class = "form-control",
                                            id = "auth_password",
                                            htmlsourceindent = "6",
                                            placeholder = "Password",
                                            type = "password",
                                        )
                                    ]
                                end
                                Genie.Renderer.Html.br(htmlsourceindent = "5")
                                Genie.Renderer.Html.input(
                                    class = "btn btn-primary",
                                    htmlsourceindent = "5",
                                    value = "login",
                                    type = "submit",
                                )
                            ]
                        end;
                    ]
                end;
            ]
        end
        Genie.Renderer.Html.style(htmlsourceindent = "2", type = "text/css") do
            [
                """
                 body {
                        margin-top: 10%;
                        font-family: "Microsoft YaHei", Georgia, 'Times New Roman', Times, serif;
                        background-color: white;
                        color:black;
                        font-size:16px;
                        }  
                  .h1 {
                    text-align:center;
                    vertical-align:text-top;
                  }
                .h2 {
                  text-align:center;
                  font-size:60px;
                  font-weight:bold;
                }
                .h3{
                  text-align:right;
                }
                .aa {
                  width:300px;
                  padding:30px;
                  padding-right:120px;
                  border:3px solid darkcyan;
                  margin:auto;
                  background-color:whitesmoke;
                }
                .aa:hover {
                  background-color:aliceblue;
                }
                """
            ]
        end
    ]
end
