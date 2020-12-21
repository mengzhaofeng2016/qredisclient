#include "mhigher.h"
#include <QDebug>

MHigher::MHigher(QQuickTextDocument *parent) : QSyntaxHighlighter(parent)
{
    if(parent){

         QSyntaxHighlighter::setDocument(parent->textDocument());
    }

    HighlightingRule rule;

    keywordFormat.setForeground(Qt::darkBlue);
    keywordFormat.setFontWeight(QFont::Bold);
    const QString keywordPatterns[] = {
        QStringLiteral("\\bchar\\b"), QStringLiteral("\\bclass\\b"), QStringLiteral("\\bconst\\b"),
        QStringLiteral("\\bdouble\\b"), QStringLiteral("\\benum\\b"), QStringLiteral("\\bexplicit\\b"),
        QStringLiteral("\\bfriend\\b"), QStringLiteral("\\binline\\b"), QStringLiteral("\\bint\\b"),
        QStringLiteral("\\blong\\b"), QStringLiteral("\\bnamespace\\b"), QStringLiteral("\\boperator\\b"),
        QStringLiteral("\\bprivate\\b"), QStringLiteral("\\bprotected\\b"), QStringLiteral("\\bpublic\\b"),
        QStringLiteral("\\bshort\\b"), QStringLiteral("\\bsignals\\b"), QStringLiteral("\\bsigned\\b"),
        QStringLiteral("\\bslots\\b"), QStringLiteral("\\bstatic\\b"), QStringLiteral("\\bstruct\\b"),
        QStringLiteral("\\btemplate\\b"), QStringLiteral("\\btypedef\\b"), QStringLiteral("\\btypename\\b"),
        QStringLiteral("\\bunion\\b"), QStringLiteral("\\bunsigned\\b"), QStringLiteral("\\bvirtual\\b"),
        QStringLiteral("\\bvoid\\b"), QStringLiteral("\\bvolatile\\b"), QStringLiteral("\\bbool\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
        //! [0] //! [1]
    }
    //! [1]

    //! [2]
    classFormat.setFontWeight(QFont::Bold);
    classFormat.setForeground(Qt::magenta);
    rule.pattern = QRegularExpression(QStringLiteral("true|false"));
    rule.format = classFormat;
    highlightingRules.append(rule);
    //! [2]
    //!
    //! [2]

    classFormat.setForeground(Qt::lightGray);
    rule.pattern = QRegularExpression(QStringLiteral("null"));
    rule.format = classFormat;
    highlightingRules.append(rule);
    //! [2]

    //! [3]
    singleLineCommentFormat.setForeground(Qt::yellow);
    rule.pattern = QRegularExpression(QStringLiteral(":[ ]*[-\\+]*[0-9\\.e\\+-]*|^[-\\+]*[0-9\\.e\\+-]*|^[\\t]*[-\\+]*[0-9\\.e\\+-]*"));
    rule.format = singleLineCommentFormat;
    highlightingRules.append(rule);

    multiLineCommentFormat.setForeground(Qt::red);
    //! [3]

    //!  //! [4]
    quotationFormat.setForeground(Qt::green);
    rule.pattern = QRegularExpression(QStringLiteral("\"[\\s\\S\r\n]*\""));
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    //! [4]

    //!  //! [4]
    quotationFormat.setForeground(Qt::green);
    rule.pattern = QRegularExpression(QStringLiteral("\"[\\s\\S\r\n]*\r"));
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    //! [4]
    //!
    //!  //! [4]
    quotationFormat.setForeground(Qt::green);
    rule.pattern = QRegularExpression(QStringLiteral(":[ ]*\".*"));
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    //! [4]
    //!
    //! //!  //! [4]
    quotationFormat.setForeground(Qt::green);
    rule.pattern = QRegularExpression(QStringLiteral("[ a-z0-9A-Z+\\-\\*_\\|]*\",$"));
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    //! [4]



    //! [4]
    quotationFormat.setForeground(Qt::darkGreen);
    rule.pattern = QRegularExpression(QStringLiteral("\".*\":|{|}|\\[|\\]|,"));
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    //! [4]



    //! [6]
    commentStartExpression = QRegularExpression(QStringLiteral("/\\*"));
    commentEndExpression = QRegularExpression(QStringLiteral("\\*/"));
}
//! [6]

//! [7]
void MHigher::highlightBlock(const QString &text)
{

    for (const HighlightingRule &rule : qAsConst(highlightingRules)) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
    //! [7] //! [8]
    setCurrentBlockState(0);
    //! [8]

    //! [9]
    int startIndex = 0;
    if (previousBlockState() != 1)
        startIndex = text.indexOf(commentStartExpression);

    //! [9] //! [10]
    while (startIndex >= 0) {
        //! [10] //! [11]
        QRegularExpressionMatch match = commentEndExpression.match(text, startIndex);
        int endIndex = match.capturedStart();
        int commentLength = 0;
        if (endIndex == -1) {
            setCurrentBlockState(1);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex
                    + match.capturedLength();
        }
        setFormat(startIndex, commentLength, multiLineCommentFormat);
        startIndex = text.indexOf(commentStartExpression, startIndex + commentLength);
    }
}
//! [11]
