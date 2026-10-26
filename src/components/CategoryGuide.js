import { categoryGuides } from '@/lib/category-guides';

export default function CategoryGuide({ category }) {
  const guide = categoryGuides[category];
  if (!guide) return null;

  return (
    <section className="learning-guide">
      <div className="learning-copy">
        <p className="eyebrow">LỘ TRÌNH HỌC GỢI Ý</p>
        <h2>{guide.title}</h2>
        <p>{guide.description}</p>
        <div className="learning-steps">
          {guide.steps.map((step, index) => (
            <span key={step}><b>{index + 1}</b>{step}</span>
          ))}
        </div>
      </div>
      <div className="learning-visual">
        <img src={guide.illustration} alt={`Sơ đồ ${guide.title}`} loading={category === 'linux' ? 'eager' : 'lazy'} />
      </div>
    </section>
  );
}
