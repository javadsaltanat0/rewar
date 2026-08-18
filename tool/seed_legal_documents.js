/**
 * Seeds `legal_documents/terms_of_service` — the one example document the
 * Terms of Service screen reads (see the "one example, seeded" rule in
 * CLAUDE.md and the tracking table in SEED_DATA.md).
 *
 * The wording here must stay in sync with `bundledTerms()` in
 * `lib/services/legal_document_service.dart`, which is the offline/preview
 * fallback of the same text.
 *
 * ⚠️ `legalReviewed: false` — the Kurdish and Arabic renderings were produced
 * by translation, not by a qualified legal translator. The app shows a
 * warning banner while this is false. Flip it to true only once the wording
 * has actually been signed off.
 *
 * Usage:
 *   1. Download a service-account key from
 *      Firebase Console → Project Settings → Service accounts.
 *      Do NOT commit it — .gitignore already covers *-service-account.json.
 *   2. cd functions && npm install && cd ..
 *   3. GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
 *        node tool/seed_legal_documents.js
 */

const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

const TERMS = {
  version: 1,
  legalReviewed: false,
  content: {
    en: {
      sections: [
        {
          heading: "YOUR AGREEMENT",
          body:
            "By using this App, you agree to be bound by, and to comply " +
            "with, these Terms and Conditions. If you do not agree to these " +
            "Terms and Conditions, please do not use this app.\n\n" +
            "PLEASE NOTE: We reserve the right, at our sole discretion, to " +
            "change, modify or otherwise alter these Terms and Conditions " +
            "at any time. Unless otherwise indicated, amendments will " +
            "become effective immediately. Please review these Terms and " +
            "Conditions periodically. Your continued use of the App " +
            "following the posting of changes and/or modifications will " +
            "constitute your acceptance of the revised Terms and Conditions " +
            "and the reasonableness of these standards for notice of " +
            "changes. For your information, this page was last updated as " +
            "of the date at the top of these terms and conditions.",
        },
        {
          heading: "PRIVACY",
          body:
            "Please review our Privacy Policy, which also governs your use " +
            "of this App, to understand our data practices regarding your " +
            "personal information, travel bookings, and reservations.",
        },
      ],
    },
    ku: {
      sections: [
        {
          heading: "ڕێککەوتننامەکەت",
          body:
            "بە بەکارهێنانی ئەم ئەپە، ڕازی دەبیت بە پابەندبوون بەم مەرج و " +
            "ڕێساییانە و جێبەجێکردنیان. ئەگەر ڕازی نیت بەم مەرج و " +
            "ڕێساییانە، تکایە ئەم ئەپە بەکارمەهێنە.\n\n" +
            "تێبینی: ئێمە مافی ئەوەمان هەیە، بە بڕیاری تەواوی خۆمان، کە لە " +
            "هەر کاتێکدا ئەم مەرج و ڕێساییانە بگۆڕین یان دەستکارییان " +
            "بکەین. مەگەر بە شێوەیەکی تر ئاماژەی پێ کرابێت، گۆڕانکارییەکان " +
            "دەستبەجێ جێبەجێ دەبن. تکایە کات بە کات ئەم مەرج و ڕێساییانە " +
            "بخوێنەوە. بەردەوامبوونت لە بەکارهێنانی ئەپەکە دوای " +
            "بڵاوکردنەوەی گۆڕانکارییەکان، بە پەسەندکردنی مەرج و ڕێسا " +
            "نوێکراوەکان و بە گونجاوی ئەم شێوازەی ئاگادارکردنەوە دادەنرێت. " +
            "بۆ زانیاریت، ئەم پەڕەیە لە بەرواری سەرەوەی ئەم مەرج و " +
            "ڕێساییانەدا نوێکراوەتەوە.",
        },
        {
          heading: "تایبەتمەندی",
          body:
            "تکایە سیاسەتی تایبەتمەندیمان بخوێنەوە، کە هەروەها بەکارهێنانی " +
            "ئەم ئەپە ڕێکدەخات، بۆ تێگەیشتن لە چۆنیەتی مامەڵەکردنمان لەگەڵ " +
            "زانیارییە کەسییەکانت و حجز و گەشتەکانت.",
        },
      ],
    },
    ar: {
      sections: [
        {
          heading: "اتفاقيتك",
          body:
            "باستخدامك هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط " +
            "والأحكام والامتثال لها. إذا كنت لا توافق على هذه الشروط " +
            "والأحكام، فيرجى عدم استخدام هذا التطبيق.\n\n" +
            "يرجى الملاحظة: نحتفظ بالحق، وفقًا لتقديرنا المطلق، في تغيير " +
            "هذه الشروط والأحكام أو تعديلها أو تبديلها في أي وقت. ما لم " +
            "يُذكر خلاف ذلك، تصبح التعديلات سارية فور نشرها. يرجى مراجعة " +
            "هذه الشروط والأحكام بشكل دوري. إن استمرارك في استخدام التطبيق " +
            "بعد نشر التغييرات و/أو التعديلات يشكّل قبولًا منك للشروط " +
            "والأحكام المعدّلة ولمعقولية هذه المعايير الخاصة بالإشعار " +
            "بالتغييرات. للعلم، جرى آخر تحديث لهذه الصفحة بالتاريخ المذكور " +
            "في أعلى هذه الشروط والأحكام.",
        },
        {
          heading: "الخصوصية",
          body:
            "يرجى مراجعة سياسة الخصوصية الخاصة بنا، والتي تحكم أيضًا " +
            "استخدامك لهذا التطبيق، لفهم ممارساتنا المتعلقة ببياناتك " +
            "الشخصية وحجوزات السفر والحجوزات الخاصة بك.",
        },
      ],
    },
  },
};

async function main() {
  await db.collection("legal_documents").doc("terms_of_service").set({
    ...TERMS,
    updatedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
    source: "manual",
  });
  console.log("Seeded legal_documents/terms_of_service (version 1).");
  console.log("NOTE: legalReviewed is false — the app will show a warning.");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
