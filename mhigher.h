#ifndef MHIGHER_H
#define MHIGHER_H

#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QRegularExpression>
#include <QQuickTextDocument>

QT_BEGIN_NAMESPACE
class QTextDocument;
QT_END_NAMESPACE

class MHigher :  public QSyntaxHighlighter
{
    Q_OBJECT
public:
    explicit MHigher(QQuickTextDocument *parent);


protected:
    void highlightBlock(const QString &text) override;
signals:

private:
    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QRegularExpression commentStartExpression;
    QRegularExpression commentEndExpression;

    QTextCharFormat keywordFormat;
    QTextCharFormat classFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat quotationFormat;
    QTextCharFormat functionFormat;
};

#endif // MHIGHER_H
