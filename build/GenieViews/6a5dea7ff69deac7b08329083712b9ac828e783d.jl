# app\resources\authentication\views\success.jl.html 

function func_6a5dea7ff69deac7b08329083712b9ac828e783d(;
    aut = Genie.Renderer.vars(:aut),
    context = Genie.Renderer.vars(:context),
    name = Genie.Renderer.vars(:name),
    fn = Genie.Renderer.vars(:fn),
)

    [
        Genie.Renderer.Html.div(
            class = "h2 bs-callout bs-callout-primary",
            htmlsourceindent = "2",
        ) do
            [
                """
                   欢迎使用平面膜振型求解！
                """
            ]
        end
        Genie.Renderer.Html.br(htmlsourceindent = "2")
        Genie.Renderer.Html.h5(htmlsourceindent = "2", style = "text-align:center") do
            [
                """今天嘅好图""";
            ]
        end
        Genie.Renderer.Html.br(htmlsourceindent = "2")
        Genie.Renderer.Html.img(class = "img", htmlsourceindent = "2", src = "/dog/$fn")
        Genie.Renderer.Html.div(
            htmlsourceindent = "2",
            style = "display:none",
            id = "nam",
        ) do
            [
                """$name""";
            ]
        end
        Genie.Renderer.Html.div(
            htmlsourceindent = "2",
            style = "display:none",
            id = "aut1",
        ) do
            [
                """$aut""";
            ]
        end
        Genie.Renderer.Html.style(htmlsourceindent = "2") do
            [
                """
                .img {
                  height:500px;
                  width:500px;
                  object-fit: contain;
                  margin-left: auto;
                  margin-right: auto;
                  display:block;
                }
                """
            ]
        end
    ]
end
