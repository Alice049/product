{
  "nbformat": 4,
  "nbformat_minor": 0,
  "metadata": {
    "colab": {
      "provenance": [],
      "authorship_tag": "ABX9TyOYBWwRfoe/iB3IwuNqpyoj",
      "include_colab_link": true
    },
    "kernelspec": {
      "name": "ir",
      "display_name": "R"
    },
    "language_info": {
      "name": "R"
    }
  },
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "view-in-github",
        "colab_type": "text"
      },
      "source": [
        "<a href=\"https://colab.research.google.com/github/Alice049/product/blob/main/Mazta_data.r\" target=\"_parent\"><img src=\"https://colab.research.google.com/assets/colab-badge.svg\" alt=\"Open In Colab\"/></a>"
      ]
    },
    {
      "cell_type": "markdown",
      "source": [
        "階層式集群利用兩兩樣本間的距離與樹狀結構將資料進行分群，可分為由上至下的分裂法，以及由下至上的聚合法，分裂法一開始會將所有資料視為一個完整的群體，在迭代過程中不斷分裂為較小群體，直到所有資料都成為單獨的個體為止。而聚合法先將每一筆資料視為單獨的一群，根據各群體之間的相似性，不斷將相似度高的兩群資料合併，直到所有資料都合併為一個大的群集為止。"
      ],
      "metadata": {
        "id": "GHEeZJ93BPGG"
      }
    },
    {
      "cell_type": "code",
      "execution_count": 2,
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "LWLv-DiXAmwb",
        "outputId": "a5b8d825-6ab3-4bea-b056-5a6abe261f05"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stderr",
          "text": [
            "Installing package into ‘/usr/local/lib/R/site-library’\n",
            "(as ‘lib’ is unspecified)\n",
            "\n",
            "Warning message:\n",
            "“package ‘stats’ is a base package, and should not be updated”\n"
          ]
        }
      ],
      "source": [
        "install.packages(\"stats\")"
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "str(mtcars)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "pjLSlEzJA58P",
        "outputId": "559b56d6-db78-447b-ef02-959f7a9a8f11"
      },
      "execution_count": 3,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "'data.frame':\t32 obs. of  11 variables:\n",
            " $ mpg : num  21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...\n",
            " $ cyl : num  6 6 4 6 8 6 8 4 4 6 ...\n",
            " $ disp: num  160 160 108 258 360 ...\n",
            " $ hp  : num  110 110 93 110 175 105 245 62 95 123 ...\n",
            " $ drat: num  3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...\n",
            " $ wt  : num  2.62 2.88 2.32 3.21 3.44 ...\n",
            " $ qsec: num  16.5 17 18.6 19.4 17 ...\n",
            " $ vs  : num  0 0 1 1 0 1 0 1 1 1 ...\n",
            " $ am  : num  1 1 1 0 0 0 0 0 0 0 ...\n",
            " $ gear: num  4 4 4 3 3 3 3 4 4 4 ...\n",
            " $ carb: num  4 4 1 1 2 1 4 2 2 4 ...\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "d<-dist(mtcars)"
      ],
      "metadata": {
        "id": "pGPNyFyxA-gV"
      },
      "execution_count": 4,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "hc<-hclust(d)\n",
        "plot(hc,hang=-1)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 437
        },
        "id": "xOLXZJL-BB2l",
        "outputId": "30130911-efe0-4f11-fb13-379e10531e02"
      },
      "execution_count": 6,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/plain": [
              "Plot with title “Cluster Dendrogram”"
            ],
            "image/png": "iVBORw0KGgoAAAANSUhEUgAAA0gAAANICAMAAADKOT/pAAADAFBMVEUAAAABAQECAgIDAwME\nBAQFBQUGBgYHBwcICAgJCQkKCgoLCwsMDAwNDQ0ODg4PDw8QEBARERESEhITExMUFBQVFRUW\nFhYXFxcYGBgZGRkaGhobGxscHBwdHR0eHh4fHx8gICAhISEiIiIjIyMkJCQlJSUmJiYnJyco\nKCgpKSkqKiorKyssLCwtLS0uLi4vLy8wMDAxMTEyMjIzMzM0NDQ1NTU2NjY3Nzc4ODg5OTk6\nOjo7Ozs8PDw9PT0+Pj4/Pz9AQEBBQUFCQkJDQ0NERERFRUVGRkZHR0dISEhJSUlKSkpLS0tM\nTExNTU1OTk5PT09QUFBRUVFSUlJTU1NUVFRVVVVWVlZXV1dYWFhZWVlaWlpbW1tcXFxdXV1e\nXl5fX19gYGBhYWFiYmJjY2NkZGRlZWVmZmZnZ2doaGhpaWlqampra2tsbGxtbW1ubm5vb29w\ncHBxcXFycnJzc3N0dHR1dXV2dnZ3d3d4eHh5eXl6enp7e3t8fHx9fX1+fn5/f3+AgICBgYGC\ngoKDg4OEhISFhYWGhoaHh4eIiIiJiYmKioqLi4uMjIyNjY2Ojo6Pj4+QkJCRkZGSkpKTk5OU\nlJSVlZWWlpaXl5eYmJiZmZmampqbm5ucnJydnZ2enp6fn5+goKChoaGioqKjo6OkpKSlpaWm\npqanp6eoqKipqamqqqqrq6usrKytra2urq6vr6+wsLCxsbGysrKzs7O0tLS1tbW2tra3t7e4\nuLi5ubm6urq7u7u8vLy9vb2+vr6/v7/AwMDBwcHCwsLDw8PExMTFxcXGxsbHx8fIyMjJycnK\nysrLy8vMzMzNzc3Ozs7Pz8/Q0NDR0dHS0tLT09PU1NTV1dXW1tbX19fY2NjZ2dna2trb29vc\n3Nzd3d3e3t7f39/g4ODh4eHi4uLj4+Pk5OTl5eXm5ubn5+fo6Ojp6enq6urr6+vs7Ozt7e3u\n7u7v7+/w8PDx8fHy8vLz8/P09PT19fX29vb39/f4+Pj5+fn6+vr7+/v8/Pz9/f3+/v7////i\nsF19AAAACXBIWXMAABJ0AAASdAHeZh94AAAgAElEQVR4nO2dCZzU5PnH32V3dmFhuW9YLvGo\nLYKgggqIgqJyqigiWpD1RsSzeK9oBQVvwQtvbWtRUWyrVP7gfYBSq1KorniheKBQ5YZl809m\n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\n+BoiBQVEChE+m78fad6oGiIFBEQKEX77kX44mUGkgIBIIcJ/h+yLl6xy/DtEyhYQKURgxr7o\nApFCBESKLhApRECk6AKRQgREii4QKURApOgCkUIERIouEClEQKToApFCBESKLhApRECk6AKR\nQgREii4QKURApOgCkUIERIouEClEQKToApFCBESKLhApRECk6AKRQgREii4QKURApOgCkUIE\nRIouEClEQKToApFCBESKLhApRECk6AKRQgREii4QKURApOgCkUIERIouEClEQKToApFCBESK\nLhApRECk6AKRQgREii4QKURApOgCkUIERIouEClEQKToApFCBESKLhApRECk6AKRQgREii4Q\nKURApOgCkUIERIouEClEQKToApFCBESKLhApRECk6AKRQgREii4QKURApOgCkUIERIouEClE\nQKToApFCBESKLhApRECk6AKRQgREii4QKURApOgCkUIERIouEClEQKToApFCBESKLhApRECk\n6AKRQgREii4QKURApOgCkUIERIouEClEQKToApFCBESKLhApRECk6AKRQgREii4QKURApOgC\nkUIERIouEClEQKToApFChB+R6tYsXrBgyddptoJI2QIihQjvIm24pDWL0+n6rU7bQaRsAZFC\nhGeR1nVle06snjXr6nHtWc8NDhtCpGwBkUKEZ5GqYvOTS7Vzi6Y6bAiRsgVEChGeRWo7yVge\nW+mwIUTKFhApRHgWKXajsXxdqcOGEClbQKQQ4VmkzicZy6O6OGwIkbIFRAoRnkWaWjR7e2Jp\n87VsmsOGEClbQKQQ4Vmkjb1ZxeCJ50+eMKicDdjksCFEyhYQKUR470facVuvYq0bKdbvgVqn\n7SBStoBIIcJXiNC2T1esqEmnCUTKFhApRCBEKLpApBCBEKHoApFCBEKEogtEChEIEYouEClE\nIEQoukCkEJGdEKFv+vZJsTdEyhIQKURkJ0Ro2103pTgXImUJiBQiECIUXSBSiECIUHSBSCEC\nIULRBSKFCIQIRReIFCJ8p+OqXfXeNscNIFK2gEghwrtIb53Yc/QKpeZ3jFXMddwOImUJiBQi\nPIv0bozFWOM1hzYcf3wj9oLDhhApW0CkEOFZpOGxBbXf9Di1+A1F+aThEIcNIVK2gEghwrNI\nLU5V/1vCBmrLE5s5bAiRsgVEChHeQ4Sq1f82s3O05StLHDaESNkCIoUIzyJ1/b32f5PLtf/H\n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\nRr2AHDxMziHrjxBW7iUnFysAfOZb90dYRBrZ6Cd9sabkhNRqesY+KlOJP0JXuf/08VvueJqa\n9xII8J1v3R9hEelpdlwyPuqXg5iRNZIcPJyFOWRDVrlf1i9eni0aVZN+W5DAd751n4fP+RFp\n6oawPgt+VZQfH+zMjjNWk4OHRXPI+iBclftF9VnvK+bcPrkLa/J20OcSGRBrl2DjMeoduGmF\n+hmMNQ0nIQcP03PI+iNMlfuNrcufji/Uzom1yTiLUKEScFBXaERSlBfHdWtYsbe1yYUcPEzO\nIeub8FTub2cP64tz2AynLUFoCJFIJNTg4SCf4LlgSMdU5/TuTn2DPBPgmkhcirbBw/R0497J\nYEbLnNDG1Ck8IfeJpYAXwi0SObRCOgFXUzliFxvLl4XgfIALQv09EUMrhHmMfeB6RssckRzm\nHmdaqL8gkCLM3xM1tEKYx9g34ZmtBSJFkDB/T9TQCmEeY9+ESKREvog4h4b5CwIGYf6e0g2t\nkEuIRApZnQ24IMzfk2hoRYqlsyUeLTwiBdy1CLwQZpEEQysMpuZnHQlEkDCLJBhaYQCRQFgI\ns0iCoRUGkkTKzYyWIK8Js0iCoRUGkkRC5R74JszXjWBohYEkkVC5B74Js0iCoRUGUutIAPgg\n5JciP7Si2kTfkJ89KBwidymiQgPCSOQuRVRoQBiJnEgAhBGIBIAEIBIAEoBIAEgAIgEgAYgE\ngAQgEgASgEgASAAiASABiASABCASABKASABIACIBIAGIBIAEIBIAEoBIAEgAIgEgAYgEgAQg\nEgASgEgASAAiASABiASABCASABKASABIACIBIAGIBIAEIBIAEoBIAEgAIgEgAYgEgAQgEgAS\ngEgASAAiASABiASABCASABKASABIACIBIAGIBIAEIBIAEoBIAEgAIgEgAYgEgAQgEgASgEgA\nSAAiASABiASABCASABKASABIACIBIAGIBIAEIBIAEoBIAEgAIgEgAYgEgAQgEgASgEgASAAi\nASABiASABCASABKASABIACIBIAGIBIAEIBIAEoBIAEgAIgEgAYgEgAQgEgASgEgASAAiASAB\niASABCASABKASABIACIBIAGIBIAEIBIAEoBIAEgAIgEgAYgEgAQgEgASgEgASAAiASABiASA\nBCASABKASABIACIBIAGIBIAEIBIAEoBI0aa4b9BnAOJApGgDkUICRIo2ECkkQKRoA5FCAkSK\n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\nAkACEAkACfw/yq+2R54s5n0AAAAASUVORK5CYII="
          },
          "metadata": {
            "image/png": {
              "width": 420,
              "height": 420
            }
          }
        }
      ]
    },
    {
      "cell_type": "markdown",
      "source": [
        "距離函數dist()根據資料矩陣計算出來的距離物件是階層式集群的關鍵\n",
        "套件{cba}中有一個subset()函數可以顯示出巨震的部分內容，所以距離矩陣橫列的第二輛車到第五輛車，而縱行名則為第一輛到第四輛。"
      ],
      "metadata": {
        "id": "pznZXAnkCPEt"
      }
    },
    {
      "cell_type": "code",
      "source": [
        "class(d)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 34
        },
        "id": "GwwGBWmtBL-d",
        "outputId": "9605515c-ec54-4f18-9dcc-4f942de6d373"
      },
      "execution_count": 7,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "'dist'"
            ],
            "text/markdown": "'dist'",
            "text/latex": "'dist'",
            "text/plain": [
              "[1] \"dist\""
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "str(d)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "epnWT9loC7dh",
        "outputId": "a95104f9-6b06-4303-d41c-e4f486386424"
      },
      "execution_count": 8,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            " 'dist' num [1:496] 0.615 54.909 98.113 210.337 65.472 ...\n",
            " - attr(*, \"Size\")= int 32\n",
            " - attr(*, \"Labels\")= chr [1:32] \"Mazda RX4\" \"Mazda RX4 Wag\" \"Datsun 710\" \"Hornet 4 Drive\" ...\n",
            " - attr(*, \"Diag\")= logi FALSE\n",
            " - attr(*, \"Upper\")= logi FALSE\n",
            " - attr(*, \"method\")= chr \"euclidean\"\n",
            " - attr(*, \"call\")= language dist(x = mtcars)\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "install.packages(\"cba\")"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "p7fx1o73DHOU",
        "outputId": "0227e767-7bb0-4d5e-a45c-c42bee69d7b3"
      },
      "execution_count": 10,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stderr",
          "text": [
            "Installing package into ‘/usr/local/lib/R/site-library’\n",
            "(as ‘lib’ is unspecified)\n",
            "\n",
            "also installing the dependency ‘proxy’\n",
            "\n",
            "\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "library(cba)\n",
        "subset(d,1:5)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 428
        },
        "id": "xzZe30N1C--d",
        "outputId": "43387935-835c-480a-f3fb-d5ca8b7dad0b"
      },
      "execution_count": 11,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stderr",
          "text": [
            "Loading required package: grid\n",
            "\n",
            "Loading required package: proxy\n",
            "\n",
            "\n",
            "Attaching package: ‘proxy’\n",
            "\n",
            "\n",
            "The following objects are masked from ‘package:stats’:\n",
            "\n",
            "    as.dist, dist\n",
            "\n",
            "\n",
            "The following object is masked from ‘package:base’:\n",
            "\n",
            "    as.matrix\n",
            "\n",
            "\n"
          ]
        },
        {
          "output_type": "display_data",
          "data": {
            "text/plain": [
              "                    Mazda RX4 Mazda RX4 Wag  Datsun 710 Hornet 4 Drive\n",
              "Mazda RX4 Wag       0.6153251                                         \n",
              "Datsun 710         54.9086059    54.8915169                           \n",
              "Hornet 4 Drive     98.1125212    98.0958939 150.9935191               \n",
              "Hornet Sportabout 210.3374396   210.3358546 265.0831615    121.0297564"
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "rownames(mtcars)[1:5]"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 34
        },
        "id": "WIonFMD9Dew-",
        "outputId": "d5270a56-9bb0-44a8-819e-0e933815101c"
      },
      "execution_count": 12,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<style>\n",
              ".list-inline {list-style: none; margin:0; padding: 0}\n",
              ".list-inline>li {display: inline-block}\n",
              ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
              "</style>\n",
              "<ol class=list-inline><li>'Mazda RX4'</li><li>'Mazda RX4 Wag'</li><li>'Datsun 710'</li><li>'Hornet 4 Drive'</li><li>'Hornet Sportabout'</li></ol>\n"
            ],
            "text/markdown": "1. 'Mazda RX4'\n2. 'Mazda RX4 Wag'\n3. 'Datsun 710'\n4. 'Hornet 4 Drive'\n5. 'Hornet Sportabout'\n\n\n",
            "text/latex": "\\begin{enumerate*}\n\\item 'Mazda RX4'\n\\item 'Mazda RX4 Wag'\n\\item 'Datsun 710'\n\\item 'Hornet 4 Drive'\n\\item 'Hornet Sportabout'\n\\end{enumerate*}\n",
            "text/plain": [
              "[1] \"Mazda RX4\"         \"Mazda RX4 Wag\"     \"Datsun 710\"       \n",
              "[4] \"Hornet 4 Drive\"    \"Hornet Sportabout\""
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "args(dist)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 86
        },
        "id": "5JwmbIL6DkJN",
        "outputId": "0456f4ca-2610-4553-c54a-3cd33c56091a"
      },
      "execution_count": 13,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<pre class=language-r><code>function (x, y = NULL, method = NULL, ..., diag = FALSE, upper = FALSE, \n",
              "<span style=white-space:pre-wrap>    pairwise = FALSE, by_rows = TRUE, convert_similarities = TRUE, </span>\n",
              "<span style=white-space:pre-wrap>    auto_convert_data_frames = TRUE) </span>\n",
              "NULL</code></pre>"
            ],
            "text/markdown": "```r\nfunction (x, y = NULL, method = NULL, ..., diag = FALSE, upper = FALSE, \n    pairwise = FALSE, by_rows = TRUE, convert_similarities = TRUE, \n    auto_convert_data_frames = TRUE) \nNULL\n```",
            "text/latex": "\\begin{minted}{r}\nfunction (x, y = NULL, method = NULL, ..., diag = FALSE, upper = FALSE, \n    pairwise = FALSE, by\\_rows = TRUE, convert\\_similarities = TRUE, \n    auto\\_convert\\_data\\_frames = TRUE) \nNULL\n\\end{minted}",
            "text/plain": [
              "function (x, y = NULL, method = NULL, ..., diag = FALSE, upper = FALSE, \n",
              "    pairwise = FALSE, by_rows = TRUE, convert_similarities = TRUE, \n",
              "    auto_convert_data_frames = TRUE) \n",
              "NULL"
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "names(hc)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 34
        },
        "id": "jQa1kNdZE2Is",
        "outputId": "a8f04bed-b48d-4bad-bac8-3e852015127a"
      },
      "execution_count": 14,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<style>\n",
              ".list-inline {list-style: none; margin:0; padding: 0}\n",
              ".list-inline>li {display: inline-block}\n",
              ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
              "</style>\n",
              "<ol class=list-inline><li>'merge'</li><li>'height'</li><li>'order'</li><li>'labels'</li><li>'method'</li><li>'call'</li><li>'dist.method'</li></ol>\n"
            ],
            "text/markdown": "1. 'merge'\n2. 'height'\n3. 'order'\n4. 'labels'\n5. 'method'\n6. 'call'\n7. 'dist.method'\n\n\n",
            "text/latex": "\\begin{enumerate*}\n\\item 'merge'\n\\item 'height'\n\\item 'order'\n\\item 'labels'\n\\item 'method'\n\\item 'call'\n\\item 'dist.method'\n\\end{enumerate*}\n",
            "text/plain": [
              "[1] \"merge\"       \"height\"      \"order\"       \"labels\"      \"method\"     \n",
              "[6] \"call\"        \"dist.method\""
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "hc$merge"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 1000
        },
        "id": "ok4MqRZQE5Jp",
        "outputId": "5697e474-0504-41b4-8c64-ffde4373ed92"
      },
      "execution_count": 15,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<table class=\"dataframe\">\n",
              "<caption>A matrix: 31 × 2 of type int</caption>\n",
              "<tbody>\n",
              "\t<tr><td> -1</td><td> -2</td></tr>\n",
              "\t<tr><td>-12</td><td>-13</td></tr>\n",
              "\t<tr><td>-10</td><td>-11</td></tr>\n",
              "\t<tr><td>-14</td><td>  2</td></tr>\n",
              "\t<tr><td>-18</td><td>-26</td></tr>\n",
              "\t<tr><td>-21</td><td>-27</td></tr>\n",
              "\t<tr><td> -7</td><td>-24</td></tr>\n",
              "\t<tr><td>-20</td><td>  5</td></tr>\n",
              "\t<tr><td> -3</td><td>  6</td></tr>\n",
              "\t<tr><td>-22</td><td>-23</td></tr>\n",
              "\t<tr><td>-19</td><td>  8</td></tr>\n",
              "\t<tr><td>-15</td><td>-16</td></tr>\n",
              "\t<tr><td>  1</td><td>  3</td></tr>\n",
              "\t<tr><td>-32</td><td>  9</td></tr>\n",
              "\t<tr><td>-29</td><td>  7</td></tr>\n",
              "\t<tr><td> -9</td><td> 14</td></tr>\n",
              "\t<tr><td> -4</td><td> -6</td></tr>\n",
              "\t<tr><td> -5</td><td>-25</td></tr>\n",
              "\t<tr><td>-17</td><td> 12</td></tr>\n",
              "\t<tr><td>-28</td><td> 16</td></tr>\n",
              "\t<tr><td>  4</td><td> 10</td></tr>\n",
              "\t<tr><td> -8</td><td> 13</td></tr>\n",
              "\t<tr><td> 20</td><td> 22</td></tr>\n",
              "\t<tr><td> 15</td><td> 18</td></tr>\n",
              "\t<tr><td> 17</td><td> 21</td></tr>\n",
              "\t<tr><td>-30</td><td> 23</td></tr>\n",
              "\t<tr><td> 19</td><td> 24</td></tr>\n",
              "\t<tr><td> 11</td><td> 26</td></tr>\n",
              "\t<tr><td>-31</td><td> 27</td></tr>\n",
              "\t<tr><td> 25</td><td> 28</td></tr>\n",
              "\t<tr><td> 29</td><td> 30</td></tr>\n",
              "</tbody>\n",
              "</table>\n"
            ],
            "text/markdown": "\nA matrix: 31 × 2 of type int\n\n|  -1 |  -2 |\n| -12 | -13 |\n| -10 | -11 |\n| -14 |   2 |\n| -18 | -26 |\n| -21 | -27 |\n|  -7 | -24 |\n| -20 |   5 |\n|  -3 |   6 |\n| -22 | -23 |\n| -19 |   8 |\n| -15 | -16 |\n|   1 |   3 |\n| -32 |   9 |\n| -29 |   7 |\n|  -9 |  14 |\n|  -4 |  -6 |\n|  -5 | -25 |\n| -17 |  12 |\n| -28 |  16 |\n|   4 |  10 |\n|  -8 |  13 |\n|  20 |  22 |\n|  15 |  18 |\n|  17 |  21 |\n| -30 |  23 |\n|  19 |  24 |\n|  11 |  26 |\n| -31 |  27 |\n|  25 |  28 |\n|  29 |  30 |\n\n",
            "text/latex": "A matrix: 31 × 2 of type int\n\\begin{tabular}{ll}\n\t  -1 &  -2\\\\\n\t -12 & -13\\\\\n\t -10 & -11\\\\\n\t -14 &   2\\\\\n\t -18 & -26\\\\\n\t -21 & -27\\\\\n\t  -7 & -24\\\\\n\t -20 &   5\\\\\n\t  -3 &   6\\\\\n\t -22 & -23\\\\\n\t -19 &   8\\\\\n\t -15 & -16\\\\\n\t   1 &   3\\\\\n\t -32 &   9\\\\\n\t -29 &   7\\\\\n\t  -9 &  14\\\\\n\t  -4 &  -6\\\\\n\t  -5 & -25\\\\\n\t -17 &  12\\\\\n\t -28 &  16\\\\\n\t   4 &  10\\\\\n\t  -8 &  13\\\\\n\t  20 &  22\\\\\n\t  15 &  18\\\\\n\t  17 &  21\\\\\n\t -30 &  23\\\\\n\t  19 &  24\\\\\n\t  11 &  26\\\\\n\t -31 &  27\\\\\n\t  25 &  28\\\\\n\t  29 &  30\\\\\n\\end{tabular}\n",
            "text/plain": [
              "      [,1] [,2]\n",
              " [1,]  -1   -2 \n",
              " [2,] -12  -13 \n",
              " [3,] -10  -11 \n",
              " [4,] -14    2 \n",
              " [5,] -18  -26 \n",
              " [6,] -21  -27 \n",
              " [7,]  -7  -24 \n",
              " [8,] -20    5 \n",
              " [9,]  -3    6 \n",
              "[10,] -22  -23 \n",
              "[11,] -19    8 \n",
              "[12,] -15  -16 \n",
              "[13,]   1    3 \n",
              "[14,] -32    9 \n",
              "[15,] -29    7 \n",
              "[16,]  -9   14 \n",
              "[17,]  -4   -6 \n",
              "[18,]  -5  -25 \n",
              "[19,] -17   12 \n",
              "[20,] -28   16 \n",
              "[21,]   4   10 \n",
              "[22,]  -8   13 \n",
              "[23,]  20   22 \n",
              "[24,]  15   18 \n",
              "[25,]  17   21 \n",
              "[26,] -30   23 \n",
              "[27,]  19   24 \n",
              "[28,]  11   26 \n",
              "[29,] -31   27 \n",
              "[30,]  25   28 \n",
              "[31,]  29   30 "
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "rownames(mtcars)[1:2]"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 34
        },
        "id": "xQeBvj-vE-Pe",
        "outputId": "d96d8b38-3faf-45e4-c069-d19ca266a4be"
      },
      "execution_count": 16,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<style>\n",
              ".list-inline {list-style: none; margin:0; padding: 0}\n",
              ".list-inline>li {display: inline-block}\n",
              ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
              "</style>\n",
              "<ol class=list-inline><li>'Mazda RX4'</li><li>'Mazda RX4 Wag'</li></ol>\n"
            ],
            "text/markdown": "1. 'Mazda RX4'\n2. 'Mazda RX4 Wag'\n\n\n",
            "text/latex": "\\begin{enumerate*}\n\\item 'Mazda RX4'\n\\item 'Mazda RX4 Wag'\n\\end{enumerate*}\n",
            "text/plain": [
              "[1] \"Mazda RX4\"     \"Mazda RX4 Wag\""
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "rownames(mtcars)[12:13]"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 34
        },
        "id": "8SzEKqisFEBT",
        "outputId": "2081ff1f-2ffd-4624-ce5d-87347c620687"
      },
      "execution_count": 17,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<style>\n",
              ".list-inline {list-style: none; margin:0; padding: 0}\n",
              ".list-inline>li {display: inline-block}\n",
              ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
              "</style>\n",
              "<ol class=list-inline><li>'Merc 450SE'</li><li>'Merc 450SL'</li></ol>\n"
            ],
            "text/markdown": "1. 'Merc 450SE'\n2. 'Merc 450SL'\n\n\n",
            "text/latex": "\\begin{enumerate*}\n\\item 'Merc 450SE'\n\\item 'Merc 450SL'\n\\end{enumerate*}\n",
            "text/plain": [
              "[1] \"Merc 450SE\" \"Merc 450SL\""
            ]
          },
          "metadata": {}
        }
      ]
    },
    {
      "cell_type": "markdown",
      "source": [
        "第一次聚合在編號1的Mazda RX4與編號2的 Mazda RX4 Wag,兩者距離為 0.615325\n",
        "第四次聚合在編號14的Merc 450SLC與前面的第二群編號12的Merc 450SE及編號13的Merc 450SL合併成一較大的群，兩者距離為"
      ],
      "metadata": {
        "id": "c9Ehl-q_DpRI"
      }
    },
    {
      "cell_type": "code",
      "source": [
        "hc$height"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 86
        },
        "id": "7YJmKF6yFJfB",
        "outputId": "44864ecf-e3b3-40ad-8d5d-5d45dbb6837c"
      },
      "execution_count": 18,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/html": [
              "<style>\n",
              ".list-inline {list-style: none; margin:0; padding: 0}\n",
              ".list-inline>li {display: inline-block}\n",
              ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
              "</style>\n",
              "<ol class=list-inline><li>0.61532511731604</li><li>0.982649479723062</li><li>1.52315462117278</li><li>2.13834047803431</li><li>5.14734154685698</li><li>8.65359029536296</li><li>10.0761202851097</li><li>10.3922856003865</li><li>13.1357108677072</li><li>14.0154994559595</li><li>14.7807070196253</li><li>15.6224446230416</li><li>15.6724726830197</li><li>20.6939435584424</li><li>21.2655989805131</li><li>33.180384265406</li><li>33.5508692137775</li><li>40.005247468301</li><li>40.8399635773589</li><li>50.1094029998363</li><li>51.8242520447715</li><li>64.889871320569</li><li>74.3824295717746</li><li>101.738968566622</li><li>103.431069316719</li><li>113.302300506212</li><li>134.811946429091</li><li>141.704447795403</li><li>214.936685793747</li><li>261.849881468371</li><li>425.344651694364</li></ol>\n"
            ],
            "text/markdown": "1. 0.61532511731604\n2. 0.982649479723062\n3. 1.52315462117278\n4. 2.13834047803431\n5. 5.14734154685698\n6. 8.65359029536296\n7. 10.0761202851097\n8. 10.3922856003865\n9. 13.1357108677072\n10. 14.0154994559595\n11. 14.7807070196253\n12. 15.6224446230416\n13. 15.6724726830197\n14. 20.6939435584424\n15. 21.2655989805131\n16. 33.180384265406\n17. 33.5508692137775\n18. 40.005247468301\n19. 40.8399635773589\n20. 50.1094029998363\n21. 51.8242520447715\n22. 64.889871320569\n23. 74.3824295717746\n24. 101.738968566622\n25. 103.431069316719\n26. 113.302300506212\n27. 134.811946429091\n28. 141.704447795403\n29. 214.936685793747\n30. 261.849881468371\n31. 425.344651694364\n\n\n",
            "text/latex": "\\begin{enumerate*}\n\\item 0.61532511731604\n\\item 0.982649479723062\n\\item 1.52315462117278\n\\item 2.13834047803431\n\\item 5.14734154685698\n\\item 8.65359029536296\n\\item 10.0761202851097\n\\item 10.3922856003865\n\\item 13.1357108677072\n\\item 14.0154994559595\n\\item 14.7807070196253\n\\item 15.6224446230416\n\\item 15.6724726830197\n\\item 20.6939435584424\n\\item 21.2655989805131\n\\item 33.180384265406\n\\item 33.5508692137775\n\\item 40.005247468301\n\\item 40.8399635773589\n\\item 50.1094029998363\n\\item 51.8242520447715\n\\item 64.889871320569\n\\item 74.3824295717746\n\\item 101.738968566622\n\\item 103.431069316719\n\\item 113.302300506212\n\\item 134.811946429091\n\\item 141.704447795403\n\\item 214.936685793747\n\\item 261.849881468371\n\\item 425.344651694364\n\\end{enumerate*}\n",
            "text/plain": [
              " [1]   0.6153251   0.9826495   1.5231546   2.1383405   5.1473415   8.6535903\n",
              " [7]  10.0761203  10.3922856  13.1357109  14.0154995  14.7807070  15.6224446\n",
              "[13]  15.6724727  20.6939436  21.2655990  33.1803843  33.5508692  40.0052475\n",
              "[19]  40.8399636  50.1094030  51.8242520  64.8898713  74.3824296 101.7389686\n",
              "[25] 103.4310693 113.3023005 134.8119464 141.7044478 214.9366858 261.8498815\n",
              "[31] 425.3446517"
            ]
          },
          "metadata": {}
        }
      ]
    }
  ]
}