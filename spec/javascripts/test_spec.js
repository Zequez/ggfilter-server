describe('RegExp', function(){
  it('should match', function(){
    expect('string').toMatch(new RegExp('^string$'));
  })

  it('shoudl be yes', function(){
    expect(POTATO).toMatch('YES!');
  })
});
