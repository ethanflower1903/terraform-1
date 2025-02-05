resource "aws_iam_policy" "mfa_required" {
  name = "${var.service}-mfa-required-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowIndividualUserToManageTheirOwnMFA"
        Effect = "Allow",
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:ListMFADevices"
        ],
        Resource = [
          "arn:aws:iam::*:mfa/*",
          "arn:aws:iam::*:user/*"
        ]
      },
      {
        Sid    = "BlockMostAccessUnlessSignedInWithMFA"
        Effect = "Deny",
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:ListMFADevices"
        ],
        Resource = "*",
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "limitation_region_tokyo" {
  name = "${var.service}-only-region-tokyo-allow"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = var.region_limitation_actions,
        Resource = "*",
        Effect   = "Deny",
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-1"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "limitation_region_osaka" {
  name = "${var.service}-only-region-osaka-allow"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = var.region_limitation_actions,
        Resource = "*",
        Effect   = "Deny",
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-3"
            ]
          }
        }
      }
    ]
  })
}

## role
resource "aws_iam_role_policy" "chatbot" {
  name = "${var.service}-chatbot-notification-policy"
  role = aws_iam_role.chatbot.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "tf_plan" {
  name = "${var.service}-tf-plan-role-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Resource = [
            "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/*",
            "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/*"
          ],
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          Effect = "Allow",
          Resource = [
            "arn:aws:s3:::codepipeline-${data.aws_region.current.id}-*"
          ],
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ]
        },
        {
          Effect = "Allow",
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ],
          Resource = [
            "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:*"
          ]
        }
      ]
    }
  )
}
