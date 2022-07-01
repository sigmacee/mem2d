# app\layouts\projlayout.jl.html 

function func_3b480da7c4f9a4d1a05a8f88ed72bca9af0b4d18(;
    aut = Genie.Renderer.vars(:aut),
    context = Genie.Renderer.vars(:context),
    name = Genie.Renderer.vars(:name),
    fn = Genie.Renderer.vars(:fn),
)

    [
        Genie.Renderer.Html.doctype()
        Genie.Renderer.Html.html(htmlsourceindent = "0", lang = "en") do
            [
                Genie.Renderer.Html.head(htmlsourceindent = "1") do
                    [
                        Genie.Renderer.Html.meta(charset = "utf-8", htmlsourceindent = "2")
                        Genie.Renderer.Html.title(htmlsourceindent = "2") do
                            [
                                """平面膜振动求解""";
                            ]
                        end
                        Genie.Renderer.Html.script(htmlsourceindent = "2") do
                            [
                                """
                                      function dispname() {
                                        document.getElementById("dispnm").innerText = document.getElementById("nam").innerText;
                                      }
                                      function checkaut() {
                                        var aut1=document.getElementById("aut1").innerText.trim();        
                                        aut1=aut1.split(",");
                                        aut0={"所有员工日志":1,"所有工单浏览":2,"所有必报浏览":3,"用户管理":4,"汽车使用新增":5,"必报写入后台":6,"加班写入后台":7};
                                        if (aut1.length>0){
                                          document.getElementById("aut").style.display="block";
                                        }
                                        for (let i=0;i < aut1.length;i++) {
                                          a=aut0[aut1[i]];
                                          if (a !== undefined){         
                                          document.getElementById(a).style.display="block";}
                                        }
                                        //document.getElementById("aut_c").value = 0;
                                      }
                                      function checktodo(){
                                			    nn = document.getElementById("nam").innerText;
                                			    data = {who: nn};
                                    			fetch('/todolist',{
                                				      method: 'POST',
                                				      headers: {
                                					        'Content-Type': 'application/json',
                                			      	},
                                				      body: JSON.stringify(data),
                                			    })
                                			    .then(response => response.json())
                                			    .then(response => {				      
                                              document.getElementById('menu20').innerText =  document.getElementById('menu20').innerText + response.待办事项;
                                              document.getElementById('menu21').innerText =  document.getElementById('menu21').innerText + '⏳' + response.审核完成必报;
                                              document.getElementById('menu22').innerText =  document.getElementById('menu22').innerText + '⏳' + response.手下加班审核;
                                              document.getElementById('menu23').innerText =  document.getElementById('menu23').innerText + '⏳' + response.确认出街文件;
                                              document.getElementById('menu70').innerText =  document.getElementById('menu70').innerText + response.权限操作;
                                              document.getElementById('6').innerText =  document.getElementById('6').innerText + '⏳' + response.必报写入后台;
                                              document.getElementById('7').innerText =  document.getElementById('7').innerText + '⏳' + response.加班写入后台;                          
                                				      //alert(response.审核完成必报);
                                			        })
                                			    .catch((error) => {
                                                alert("未取得待办事项:" + error);
                                			    })
                                      }
                                    """
                            ]
                        end
                        Genie.Renderer.Html.style(htmlsourceindent = "2") do
                            [
                                """
                                        h6{
                                            text-align: right
                                        }
                                        body {
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
                                            font-family: 'Times New Roman', Times, serif;
                                            text-align:center;
                                            font-size:60px;
                                            font-weight:bold;
                                        }
                                        .h3{
                                            text-align:right;
                                        }
                                        .h4{
                                            text-align:left;
                                        }
                                        .aa {
                                            width:800px;
                                            padding:30px;
                                            padding-right:120px;
                                            border:3px solid darkcyan;
                                            margin:auto;
                                            box-shadow: 0 2px 4px 0 rgba(0,0,0,.2);
                                            background-color:whitesmoke;
                                         }
                                         h3{ 
                                           margin-left: 50px;
                                         }
                                a:link {
                                  color: lightseagreen;
                                  background-color: transparent;
                                  text-decoration: none;
                                }
                                a:visited {
                                  color: darkcyan;
                                  background-color: transparent;
                                  text-decoration: none;
                                }
                                a:hover {
                                  color: darkslateblue;
                                  background-color: transparent;
                                  text-decoration: underline;
                                }
                                a:active {
                                  color: yellow;
                                  background-color: transparent;
                                  text-decoration: underline;
                                }
                                .navi {
                                  background-color: black;
                                  overflow:hidden;
                                  margin-left: -8px;
                                  margin-right:-8px;
                                  margin-top: -8px;
                                  box-shadow: 0 2px 4px 0 rgba(0,0,0,.2);
                                }
                                .navi a {
                                  float: left;
                                  color: #f2f2f2;
                                  text-align: center;
                                  padding: 14px 16px;
                                  text-decoration: none;
                                  font-size: 20px;
                                }
                                .navi a:hover, .dropdown:hover .dropbtn {
                                  background-color: #ddd;
                                  color: black;
                                }
                                .dropdown {
                                  float:left;
                                  overflow:hidden;
                                }
                                .dropdown:hover .dropdown1 {
                                  display:block;
                                }
                                .dropdown1 {
                                  display:none;
                                  position:absolute;
                                  background-color: #f2f2f2;
                                  min-width:150px;
                                  z-index: 1;
                                  box-shadow: 0 2px 4px 0 rgba(0,0,0,.2);
                                }
                                .dropdown1 a {
                                  float:none;
                                  color: black;
                                  padding: 12px 16px;
                                  text-decoration: none;
                                  display: block;
                                }
                                .dropdown:hover .dropdown2 {
                                  display:block;
                                  right:0;
                                }
                                .dropdown2 {
                                  display:none;
                                  position:absolute;
                                  background-color: #f2f2f2;
                                  min-width:150px;
                                  z-index: 1;
                                  box-shadow: 0 2px 4px 0 rgba(0,0,0,.2);
                                }
                                .dropdown2 a {
                                  float:none;
                                  color: black;
                                  padding: 12px 16px;
                                  text-decoration: none;
                                  display: block;
                                }
                                .dropdown .dropbtn {
                                  font-size: 20px;
                                  border: none;
                                  outline: none;
                                  color: white;
                                  padding: 14px 16px;
                                  background-color: inherit;
                                }
                                .aa:hover {
                                  background-color:aliceblue;
                                }
                                    """
                            ]
                        end
                    ]
                end
                Genie.Renderer.Html.body(htmlsourceindent = "1", onload = "dispname();") do
                    [
                        Genie.Renderer.Html.div(class = "navi", htmlsourceindent = "2") do
                            [
                                Genie.Renderer.Html.div(
                                    class = "dropdown",
                                    htmlsourceindent = "3",
                                ) do
                                    [
                                        Genie.Renderer.Html.button(
                                            class = "dropbtn",
                                            id = "menu20",
                                            htmlsourceindent = "4",
                                        ) do
                                            [
                                                """FixedBoundary2D
                                                        """
                                            ]
                                        end
                                        Genie.Renderer.Html.div(
                                            class = "dropdown1",
                                            htmlsourceindent = "4",
                                        ) do
                                            [
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu21",
                                                    href = "/rect4",
                                                ) do
                                                    [
                                                        """Rectangle""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu22",
                                                    href = "/lshape4",
                                                ) do
                                                    [
                                                        """Lshape""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu23",
                                                    href = "/tri3",
                                                ) do
                                                    [
                                                        """Triangle""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu21",
                                                    href = "/circle3",
                                                ) do
                                                    [
                                                        """Circle""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu21",
                                                    href = "/sector3",
                                                ) do
                                                    [
                                                        """Sector""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu21",
                                                    href = "/line2",
                                                ) do
                                                    [
                                                        """Line""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu21",
                                                    href = "/trapezoid43",
                                                ) do
                                                    [
                                                        """Trapezoid""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    id = "menu21",
                                                    href = "/polygon3",
                                                ) do
                                                    [
                                                        """Polygon""";
                                                    ]
                                                end
                                            ]
                                        end
                                    ]
                                end
                                Genie.Renderer.Html.div(
                                    class = "dropdown",
                                    style = "float:right",
                                    htmlsourceindent = "3",
                                ) do
                                    [
                                        Genie.Renderer.Html.button(
                                            class = "dropbtn",
                                            id = "dispnm",
                                            htmlsourceindent = "4",
                                        ) do
                                            [
                                                """当前用户
                                                        """
                                            ]
                                        end
                                        Genie.Renderer.Html.div(
                                            class = "dropdown2",
                                            htmlsourceindent = "4",
                                        ) do
                                            [
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    href = "/changepw",
                                                ) do
                                                    [
                                                        """ChangePW""";
                                                    ]
                                                end
                                                Genie.Renderer.Html.a(
                                                    htmlsourceindent = "5",
                                                    href = "/logout",
                                                ) do
                                                    [
                                                        """Logout""";
                                                    ]
                                                end
                                            ]
                                        end
                                    ]
                                end
                            ]
                        end
                        Genie.Renderer.Html.br(htmlsourceindent = "2")
                        @yield
                    ]
                end
            ]
        end
    ]
end
