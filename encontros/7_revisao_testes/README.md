
## Para a realização dos testes do pre-commit é necessário instalar:

Primeiramente, instale essas dependências do [Pre-commit Terraform](https://github.com/antonbabenko/pre-commit-terraform#1-install-dependencies), como:

[TFLint](https://github.com/terraform-linters/tflint)
[TFSec](https://github.com/aquasecurity/tfsec)

Depois disso, instale o Pre-commit:

[Pre-commit](https://pre-commit.com/): [Aqui no final](https://github.com/antonbabenko/pre-commit-terraform#1-install-dependencies) tem uma aba Windows com dicas de como instalar pre-commit no Windows.

Perceba também a existência [desse package manager para Windows](https://community.chocolatey.org/), o qual eu desconhecia.

## Debugando testes no VSCode:

Segue abaixo o `launch.json` do VSCode utilizado para debugar os testes do [pytest](https://docs.pytest.org/en/7.4.x/).

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Debug Tests",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "purpose": ["debug-test"],
            "console": "integratedTerminal",
            // "justMyCode": false,
            "env": {
                "PYTHONPATH": "${workspaceFolder}"
            }
          }
    ]
}
```

Para mais informações de DEBUG no Python, [acesse aqui](https://code.visualstudio.com/docs/python/debugging).
